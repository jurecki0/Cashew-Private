import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addInvestmentPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart'; // Consider renaming this widget in future
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart'; // Consider renaming this widget to InvestmentEntry
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/countNumber.dart';

class InvestmentsPage extends StatefulWidget {
  const InvestmentsPage({Key? key}) : super(key: key);

  @override
  State<InvestmentsPage> createState() => InvestmentsPageState();
}

enum SelectedInvestmentsType {
  monthly,
  yearly,
  total,
}

class InvestmentsPageState extends State<InvestmentsPage> {
  SelectedInvestmentsType selectedType = SelectedInvestmentsType
      .values[appStateSettings["selectedInvestmentType"]];
  GlobalKey<PageFrameworkState> pageState = GlobalKey();
  InvestmentType? selectedInvestmentType;

  void scrollToTop() {
    pageState.currentState?.scrollToTop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if ((globalSelectedID.value["Investments"] ?? []).length > 0) {
          globalSelectedID.value["Investments"] = [];
          globalSelectedID.notifyListeners();
          return false;
        } else {
          return true;
        }
      },
      child: PageFramework(
        key: pageState,
        listID: "Investments",
        floatingActionButton: AnimateFABDelayed(
          fab: AddFAB(
            tooltip: "add-investment".tr(),
            openPage: AddInvestmentPage(
              selectedInvestmentType: selectedInvestmentType, // Pass selected type
            ),
          ),
        ),
        dragDownToDismiss: true,
        title: "investments".tr(),
        actions: [
          CustomPopupMenuButton(
            showButtons: enableDoubleColumn(context),
            keepOutFirst: true,
            items: [
              DropdownItemMenu(
                id: "settings",
                label: "settings".tr(),
                icon: appStateSettings["outlinedIcons"]
                    ? Icons.settings_outlined
                    : Icons.settings_rounded,
                action: () {
                  openBottomSheet(
                    context,
                    PopupFramework(
                      hasPadding: false,
                      child: InvestmentSettings(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
        slivers: [
          // Investment Type Dropdown
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<InvestmentType>(
                value: selectedInvestmentType,
                hint: Text("select-investment-type".tr()),
                onChanged: (InvestmentType? newType) {
                  setState(() {
                    selectedInvestmentType = newType;
                  });
                },
                items: InvestmentType.values.map<DropdownMenuItem<InvestmentType>>(
                  (InvestmentType value) {
                    return DropdownMenuItem<InvestmentType>(
                      value: value,
                      child: Text(value.toString().split('.').last.tr()),
                    );
                  },
                ).toList(),
              ),
            ),
          ),
          StreamBuilder<List<Investment>>(
            stream: database.getAllInvestments(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return SliverToBoxAdapter(
                      child: NoResults(
                          padding: const EdgeInsetsDirectional.only(
                            top: 15,
                            end: 30,
                            start: 30,
                          ),
                          message: "no-investments".tr())); // Changed to "no-investments"
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      Investment investment = snapshot.data![index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HorizontalBreak(
                              padding: EdgeInsetsDirectional.only(
                                  top: 4, bottom: 6)),
                          TransactionEntry(
                            //aboveWidget: UpcomingInvestmentDateHeader( // Consider creating a new UpcomingInvestmentDateHeader widget
                              selectedType: selectedType,
                              transaction: transaction,
                            //),
                            openPage: AddInvestmentPage(
                              //investment: investment,
                              //routesToPopAfterDelete: RoutesToPopAfterDelete.One,
                            ),
                            transaction: transaction,
                            listID: "Investments",
                          ),
                        ],
                      );
                    },
                    childCount: snapshot.data?.length,
                  ),
                );
              } else {
                return SliverToBoxAdapter();
              }
            },
          ),
          SliverToBoxAdapter(child: SizedBox(height: 55)),
        ],
        selectedTransactionsAppBar: SelectedTransactionsAppBar( // Consider renaming this widget to SelectedInvestmentsAppBar
          pageID: "Investments",
        ),
      ),
    );
  }
}

class InvestmentSettings extends StatelessWidget {
  const InvestmentSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AutoPayInvestmentsSetting(),
        //AutoPaySettingDescription(), // Uncomment if needed for investment settings
      ],
    );
  }
}

class AutoPayInvestmentsSetting extends StatelessWidget {
  const AutoPayInvestmentsSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "pay-investments".tr(),
      description: "pay-investments-description".tr(),
      onSwitched: (value) async {
        // Update setting for automatic investment payments
        await updateSettings("automaticallyPayInvestments", value,
            updateGlobalState: false);
        //await setUpcomingNotifications(context); // Uncomment if applicable
      },
      initialValue: appStateSettings["automaticallyPayInvestments"],
      icon: getTransactionTypeIcon(TransactionSpecialType.investment),
    );
  }
}