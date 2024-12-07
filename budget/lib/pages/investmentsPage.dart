import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/incomeAmountArrow.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';

class InvestmentsPage extends StatefulWidget {
  const InvestmentsPage({Key? key}) : super(key: key);

  @override
  State<InvestmentsPage> createState() => InvestmentsPageState();
}

class InvestmentsPageState extends State<InvestmentsPage> {
  GlobalKey<PageFrameworkState> pageState = GlobalKey();

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
            openPage: AddTransactionPage(
              selectedType: TransactionSpecialType.investment,
              routesToPopAfterDelete: RoutesToPopAfterDelete.None,
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
          SliverToBoxAdapter(
            child: TotalInvestmentHeader(),
          ),
          StreamBuilder<List<Transaction>>(
            stream: database.getAllInvestments().$1,
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
                      message: "no-investment-transactions".tr(),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      Transaction transaction = snapshot.data![index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HorizontalBreak(
                            padding:
                                EdgeInsetsDirectional.only(top: 4, bottom: 6),
                          ),
                          TransactionEntry(
                            transaction: transaction,
                            openPage: AddTransactionPage(
                              transaction: transaction,
                              routesToPopAfterDelete:
                                  RoutesToPopAfterDelete.One,
                            ),
                            listID: "Investments",
                          ),
                        ],
                      );
                    },
                    childCount: snapshot.data?.length,
                  ),
                );
              } else {
                return const SliverToBoxAdapter();
              }
            },
          ),
          SliverToBoxAdapter(child: SizedBox(height: 55)),
        ],
        selectedTransactionsAppBar: SelectedTransactionsAppBar(
          pageID: "Investments",
        ),
      ),
    );
  }
}

class TotalInvestmentHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 30, start: 20, end: 20, bottom: 35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          StreamBuilder<List<Transaction>>(
            stream: database.getAllInvestments().$1,
            builder: (context, snapshot) {
              double total = getTotalInvestments(
                Provider.of<AllWallets>(context),
                snapshot.data,
              );
              return AmountWithColorAndArrow(
                showIncomeArrow: true,
                totalSpent: total,
                fontSize: 30,
                iconSize: 30,
                iconWidth: 20,
                textColor: getColor(context, "black"),
              );
            },
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(top: 5),
            child: AnimatedSizeSwitcher(
              child: TextFont(
                text: "total-investments".tr(),
                fontSize: 16,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InvestmentSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InvestmentSettingDescription(),
      ],
    );
  }
}

class InvestmentSettingDescription extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        "investment-settings-description".tr(),
        textAlign: TextAlign.center,
      ),
    );
  }
}
