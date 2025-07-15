import 'package:collection/collection.dart';

import '../../../../models/irma_configuration.dart';
import '../../../../util/con_dis_con.dart';
import '../models/choosable_disclosure_credential.dart';
import '../models/disclosure_credential.dart';
import '../models/template_disclosure_credential.dart';

abstract class DisclosurePermissionBlocState {}

/// Initial state to give us time to process the initial request from the IrmaBridge.
class DisclosurePermissionInitial implements DisclosurePermissionBlocState {}

/// State for showing the introduction when the user enters this flow for the first time.
class DisclosurePermissionIntroduction implements DisclosurePermissionBlocState {}

/// Enum with all possible DisclosurePermissionSteps.
enum DisclosurePermissionStepName { issueWizard, previouslyAddedCredentialsOverview, choicesOverview }

/// Abstract class containing all behaviour of a state that is a planned step.
abstract class DisclosurePermissionStep implements DisclosurePermissionBlocState {
  /// List with all the planned steps.
  final UnmodifiableListView<DisclosurePermissionStepName> plannedSteps;

  DisclosurePermissionStep({required List<DisclosurePermissionStepName> plannedSteps})
    : plannedSteps = UnmodifiableListView(plannedSteps);

  /// Index of the current step in the list of planned steps.
  DisclosurePermissionStepName get currentStepName;

  /// Index of the current step in the list of planned steps.
  int get currentStepIndex => plannedSteps.indexWhere((stepName) => stepName == currentStepName);
}

/// Abstract class containing all behaviour for states that contain disclosure choices.
abstract class DisclosurePermissionChoices extends DisclosurePermissionStep {
  /// Map with all required choices. For each choice, the currently selected option is included as map value.
  /// In required choices a choice between one of the options must be made.
  final UnmodifiableMapView<int, Con<ChoosableDisclosureCredential>> requiredChoices;

  /// Map with all optional choices. For each choice, the currently selected option is included as map value.
  /// Optional choices can be deselected.
  final UnmodifiableMapView<int, Con<ChoosableDisclosureCredential>> optionalChoices;

  /// Set that specifies which choices can be changed.
  final UnmodifiableSetView<int> changeableChoices;

  /// Is true if there are more choices available to extend optionalChoices with.
  final bool hasAdditionalOptionalChoices;

  DisclosurePermissionChoices({
    required super.plannedSteps,
    required Map<int, Con<ChoosableDisclosureCredential>> requiredChoices,
    required Map<int, Con<ChoosableDisclosureCredential>> optionalChoices,
    required Set<int> changeableChoices,
    required this.hasAdditionalOptionalChoices,
  }) : requiredChoices = UnmodifiableMapView(requiredChoices),
       optionalChoices = UnmodifiableMapView(optionalChoices),
       changeableChoices = UnmodifiableSetView(changeableChoices);

  Map<int, Con<ChoosableDisclosureCredential>> get choices => {...requiredChoices, ...optionalChoices};

  /// Returns whether the selected choices are valid.
  bool get choicesValid => choices.values.flattened.every((cred) => cred.valid);

  /// Returns whether the selected choices are valid or can be made valid.
  bool get choicesCanBeValid => choices.values.flattened.every((cred) => cred.valid || cred.obtainable);
}

class DisclosurePermissionIssueWizard extends DisclosurePermissionStep {
  /// ConDisCon with all disclosure candidates being relevant in this step (required and optional).
  /// They are stored in a map with the disconIndex being used as map key. This map is not ordered.
  /// For a list of candidates in the order of the wizard, use candidatesList.
  final UnmodifiableMapView<int, DisCon<TemplateDisclosureCredential>> candidates;

  /// Ordered list with all disclosure candidates being relevant in this step (required and optional).
  /// It is an ordered representation of candidates.
  final UnmodifiableListView<MapEntry<int, DisCon<TemplateDisclosureCredential>>> candidatesList;

  /// Stores for every discon which con is currently selected.
  final UnmodifiableMapView<int, int> selectedConIndices;

  final UnmodifiableMapView<int, bool> obtained;

  DisclosurePermissionIssueWizard({
    required super.plannedSteps,
    required Map<int, DisCon<TemplateDisclosureCredential>> candidates,
    required List<MapEntry<int, DisCon<TemplateDisclosureCredential>>> candidatesList,
    required Map<int, int> selectedConIndices,
    required Map<int, bool> obtained,
  }) : assert(candidates.keys.every((i) => selectedConIndices.containsKey(i) && obtained.containsKey(i))),
       candidates = UnmodifiableMapView(candidates),
       candidatesList = UnmodifiableListView(candidatesList),
       selectedConIndices = UnmodifiableMapView(selectedConIndices),
       obtained = UnmodifiableMapView(obtained);

  /// Returns the discon that should currently be handled.
  MapEntry<int, DisCon<TemplateDisclosureCredential>>? get currentDiscon =>
      candidatesList.firstWhereOrNull((entry) => !obtained[entry.key]!);

  /// Returns the selected con in the discon that should currently be handled.
  Con<TemplateDisclosureCredential>? get currentCon => currentDiscon?.value[selectedConIndices[currentDiscon!.key]!];

  /// Returns whether the currently selected con in the issue wizard can be completed.
  bool get currentCanBeCompleted => currentCon?.every((cred) => cred.obtainable) ?? true;

  /// Returns whether the issue wizard is completed.
  bool get isCompleted => obtained.values.every((match) => match);

  @override
  DisclosurePermissionStepName get currentStepName => DisclosurePermissionStepName.issueWizard;

  /// Returns for the given disconIndex the selected con.
  Con<TemplateDisclosureCredential>? getSelectedCon(int disconIndex) =>
      candidates[disconIndex]?[selectedConIndices[disconIndex]!];
}

class DisclosurePermissionPreviouslyAddedCredentialsOverview extends DisclosurePermissionChoices {
  DisclosurePermissionPreviouslyAddedCredentialsOverview({
    required super.plannedSteps,
    required super.requiredChoices,
    required super.optionalChoices,
    required super.changeableChoices,
    required super.hasAdditionalOptionalChoices,
  });

  @override
  DisclosurePermissionStepName get currentStepName => DisclosurePermissionStepName.previouslyAddedCredentialsOverview;
}

class DisclosurePermissionChoicesOverview extends DisclosurePermissionChoices {
  /// Message to be signed, in case of a signature session.
  final String? signedMessage;

  /// Returns whether the session is a signature session.
  bool get isSignatureSession => signedMessage != null;

  /// Returns whether the popup should be shown that asks for confirmation to share data.
  final bool showConfirmationPopup;

  DisclosurePermissionChoicesOverview({
    required super.plannedSteps,
    required super.requiredChoices,
    required super.optionalChoices,
    required super.changeableChoices,
    required super.hasAdditionalOptionalChoices,
    required this.signedMessage,
    this.showConfirmationPopup = false,
  });

  @override
  DisclosurePermissionStepName get currentStepName => DisclosurePermissionStepName.choicesOverview;
}

class DisclosurePermissionObtainCredentials implements DisclosurePermissionBlocState {
  /// Link to the state that initiated this SubIssueWizard.
  final DisclosurePermissionBlocState parentState;

  /// Templates of all DisclosureCredentials that needs to be obtained first.
  final UnmodifiableListView<TemplateDisclosureCredential> templates;

  /// Returns for each issue wizard item whether a matching credential has been successfully obtained.
  final UnmodifiableListView<bool> obtained;

  /// Returns whether all issue wizard items have a matching credential.
  bool get allObtained => obtained.every((match) => match);

  /// Returns the current issue wizard item.
  TemplateDisclosureCredential? get currentIssueWizardItem =>
      templates.firstWhereIndexedOrNull((i, item) => !obtained[i]);

  DisclosurePermissionObtainCredentials({
    required this.parentState,
    required List<TemplateDisclosureCredential> templates,
    List<bool>? obtained,
  }) : assert(obtained == null || obtained.length == templates.length),
       templates = UnmodifiableListView(templates),
       obtained = UnmodifiableListView(obtained ?? List.filled(templates.length, false));
}

/// Abstract state containing all overlapping behaviour between DisclosurePermissionChangeChoice
/// and DisclosurePermissionAddOptionalData.
abstract class DisclosurePermissionMakeChoice implements DisclosurePermissionBlocState {
  /// Link to the state that initiated this state.
  final DisclosurePermissionChoices parentState;

  /// DisCon that should be changed.
  final DisCon<DisclosureCredential> discon;

  /// Index of the Con within this DisCon that is currently selected.
  final int selectedConIndex;

  DisclosurePermissionMakeChoice({required this.parentState, required this.discon, required this.selectedConIndex})
    : assert(selectedConIndex < discon.length);

  /// Returns a map with all con indices that are choosable and the corresponding Cons as map value.
  Map<int, Con<ChoosableDisclosureCredential>> get choosableCons => {
    for (int i = 0; i < discon.length; i++)
      if (discon[i].every((cred) => cred is ChoosableDisclosureCredential))
        i: Con(discon[i].whereType<ChoosableDisclosureCredential>()),
  };

  /// All template cons within this choice. This also includes choices with combinations of
  /// ChoosableDisclosureCredentials and TemplateDisclosureCredentials. Of those choices,
  /// only the TemplateDisclosureCredentials are returned.
  Map<int, Con<TemplateDisclosureCredential>> get templateCons => {
    for (int i = 0; i < discon.length; i++)
      if (discon[i].any((cred) => cred is TemplateDisclosureCredential))
        i: Con(discon[i].whereType<TemplateDisclosureCredential>()),
  };

  /// The con that is currently selected.
  Con<DisclosureCredential> get selectedCon => discon[selectedConIndex];

  /// Returns whether the current selected con is fully choosable.
  bool get isSelectedChoosable => choosableCons.containsKey(selectedConIndex);
}

class DisclosurePermissionChangeChoice extends DisclosurePermissionMakeChoice {
  /// Index of the DisCon within the disclosure candidates ConDisCon.
  final int disconIndex;

  DisclosurePermissionChangeChoice({
    required super.parentState,
    required super.discon,
    required super.selectedConIndex,
    required this.disconIndex,
  });

  /// Returns whether the given DisclosureCredential is involved in this choice.
  bool contains(DisclosureCredential credential) => discon.any((con) => con.any((cred) => cred == credential));
}

class DisclosurePermissionAddOptionalData extends DisclosurePermissionMakeChoice {
  /// List that specifies to which disconIndex every Con belongs.
  final UnmodifiableListView<int> disconIndices;

  DisclosurePermissionAddOptionalData({
    required super.parentState,
    required super.discon,
    required super.selectedConIndex,
    required List<int> disconIndices,
  }) : disconIndices = UnmodifiableListView(disconIndices);

  /// Returns the disconIndex of the con that is currently selected.
  int get disconIndexSelectedCon => disconIndices[selectedConIndex];
}

class DisclosurePermissionWrongCredentialsObtained implements DisclosurePermissionBlocState {
  /// Link to the underlying state.
  final DisclosurePermissionBlocState parentState;

  /// List with templates of the DisclosureCredentials that were expected to be obtained.
  final UnmodifiableListView<TemplateDisclosureCredential> templates;

  /// List with the credentials that were obtained by the user, but do not match the expected template.
  final UnmodifiableListView<ChoosableDisclosureCredential> obtainedCredentials;

  DisclosurePermissionWrongCredentialsObtained({
    required this.parentState,
    required List<TemplateDisclosureCredential> templates,
    required List<ChoosableDisclosureCredential> obtainedCredentials,
  }) : templates = UnmodifiableListView(templates),
       obtainedCredentials = UnmodifiableListView(obtainedCredentials);
}

class DisclosurePermissionCredentialInformation implements DisclosurePermissionBlocState {
  final DisclosurePermissionBlocState parentState;
  final CredentialType credentialType;

  DisclosurePermissionCredentialInformation({required this.parentState, required this.credentialType});
}

/// State to indicate that the requestDisclosurePermission phase has been finished.
/// This does not necessarily have to mean the total session is completed.
class DisclosurePermissionFinished implements DisclosurePermissionBlocState {}
