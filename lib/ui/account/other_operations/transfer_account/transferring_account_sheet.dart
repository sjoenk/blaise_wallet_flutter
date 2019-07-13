import 'dart:async';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:blaise_wallet_flutter/appstate_container.dart';
import 'package:blaise_wallet_flutter/bus/authenticated_event.dart';
import 'package:blaise_wallet_flutter/service_locator.dart';
import 'package:blaise_wallet_flutter/store/account/account.dart';
import 'package:blaise_wallet_flutter/ui/account/other_operations/transfer_account/transferred_account_sheet.dart';
import 'package:blaise_wallet_flutter/ui/util/app_icons.dart';
import 'package:blaise_wallet_flutter/ui/util/routes.dart';
import 'package:blaise_wallet_flutter/ui/util/text_styles.dart';
import 'package:blaise_wallet_flutter/ui/widgets/buttons.dart';
import 'package:blaise_wallet_flutter/ui/widgets/pin_screen.dart';
import 'package:blaise_wallet_flutter/ui/widgets/sheets.dart';
import 'package:blaise_wallet_flutter/util/authentication.dart';
import 'package:blaise_wallet_flutter/util/haptic_util.dart';
import 'package:blaise_wallet_flutter/util/ui_util.dart';
import 'package:blaise_wallet_flutter/util/vault.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:pascaldart/pascaldart.dart';

class TransferringAccountSheet extends StatefulWidget {
  final String publicKeyDisplay;
  final PascalAccount account;
  final Currency fee;

  TransferringAccountSheet(
      {@required this.publicKeyDisplay,
      @required this.account,
      @required this.fee});

  _TransferringAccountSheetState createState() =>
      _TransferringAccountSheetState();
}

class _TransferringAccountSheetState extends State<TransferringAccountSheet> {
  Account accountState;
  OverlayEntry _overlay;

  StreamSubscription<AuthenticatedEvent> _authSub;

  void _registerBus() {
    _authSub = EventTaxiImpl.singleton()
        .registerTo<AuthenticatedEvent>()
        .listen((event) {
      if (event.authType == AUTH_EVENT_TYPE.TRANSFER) {
        doTransfer();
      }
    });
  }

  void _destroyBus() {
    if (_authSub != null) {
      _authSub.cancel();
    }
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _registerBus();
    this.accountState = walletState.getAccountState(widget.account);
  }

  void showOverlay(BuildContext context) {
    OverlayState overlayState = Overlay.of(context);
    _overlay = OverlayEntry(
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          color: StateContainer.of(context).curTheme.overlay20,
          child: Center(
            child: //Container for the animation
                Container(
              margin: EdgeInsetsDirectional.only(
                  top: MediaQuery.of(context).padding.top),
              //Width/Height ratio for the animation is needed because BoxFit is not working as expected
              width: double.maxFinite,
              height: MediaQuery.of(context).size.width,
              child: Center(
                child: FlareActor(
                  StateContainer.of(context).curTheme.animationTransfer,
                  animation: "main",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlayState.insert(_overlay);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: StateContainer.of(context).curTheme.backgroundPrimary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: <Widget>[
                // Sheet header
                Container(
                  height: 60,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    gradient:
                        StateContainer.of(context).curTheme.gradientPrimary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Close Button
                      Container(
                        margin: EdgeInsetsDirectional.only(start: 5, end: 10),
                        height: 50,
                        width: 50,
                        child: FlatButton(
                            highlightColor:
                                StateContainer.of(context).curTheme.textLight15,
                            splashColor:
                                StateContainer.of(context).curTheme.textLight30,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0)),
                            padding: EdgeInsets.all(0.0),
                            child: Icon(AppIcons.close,
                                color: StateContainer.of(context)
                                    .curTheme
                                    .textLight,
                                size: 20)),
                      ),
                      // Header
                      Container(
                        width: MediaQuery.of(context).size.width - 130,
                        alignment: Alignment(0, 0),
                        child: AutoSizeText(
                          "TRANSFERRING",
                          style: AppStyles.header(context),
                          maxLines: 1,
                          stepGranularity: 0.1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Sized Box
                      SizedBox(
                        height: 50,
                        width: 65,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Paragraph
                      Container(
                        width: double.maxFinite,
                        margin: EdgeInsetsDirectional.fromSTEB(30, 40, 30, 0),
                        child: AutoSizeText(
                          "Confirm the public key to transfer the ownership of this account.",
                          style: AppStyles.paragraph(context),
                          stepGranularity: 0.1,
                          maxLines: 3,
                          minFontSize: 8,
                        ),
                      ),
                      // "Public Key" header
                      Container(
                        margin: EdgeInsetsDirectional.fromSTEB(30, 30, 30, 0),
                        child: AutoSizeText(
                          "Public Key",
                          style: AppStyles.textFieldLabel(context),
                          maxLines: 1,
                          stepGranularity: 0.1,
                          textAlign: TextAlign.start,
                        ),
                      ),
                      // Container for the public key
                      Container(
                        margin: EdgeInsetsDirectional.fromSTEB(30, 12, 30, 0),
                        padding: EdgeInsetsDirectional.fromSTEB(24, 12, 24, 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              width: 1,
                              color: StateContainer.of(context)
                                  .curTheme
                                  .textDark15),
                          color: StateContainer.of(context).curTheme.textDark10,
                        ),
                        child: AutoSizeText(
                          widget.publicKeyDisplay,
                          maxLines: 4,
                          stepGranularity: 0.1,
                          minFontSize: 8,
                          textAlign: TextAlign.center,
                          style: AppStyles.privateKeyTextDark(context),
                        ),
                      ),
                      // "Fee" header
                      widget.fee != Currency('0')
                          ? Container(
                              margin:
                                  EdgeInsetsDirectional.fromSTEB(30, 30, 30, 0),
                              child: AutoSizeText(
                                "Fee",
                                style: AppStyles.textFieldLabel(context),
                                maxLines: 1,
                                stepGranularity: 0.1,
                                textAlign: TextAlign.start,
                              ),
                            )
                          : SizedBox(),
                      // Container for the fee
                      widget.fee.toStringOpt() != "0"
                          ? Container(
                              margin:
                                  EdgeInsetsDirectional.fromSTEB(30, 12, 30, 0),
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    width: 1,
                                    color: StateContainer.of(context)
                                        .curTheme
                                        .primary15),
                                color: StateContainer.of(context)
                                    .curTheme
                                    .primary10,
                              ),
                              child: AutoSizeText.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "",
                                      style: AppStyles
                                          .iconFontPrimaryBalanceSmallPascal(
                                              context),
                                    ),
                                    TextSpan(
                                        text: " ",
                                        style: TextStyle(fontSize: 8)),
                                    TextSpan(
                                        text: widget.fee.toStringOpt(),
                                        style: AppStyles.balanceSmall(context)),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                minFontSize: 8,
                                stepGranularity: 1,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : SizedBox()
                    ],
                  ),
                ),
                // "CONFIRM" button
                Row(
                  children: <Widget>[
                    AppButton(
                      type: AppButtonType.Primary,
                      text: "CONFIRM",
                      buttonTop: true,
                      onPressed: () async {
                        if (await authenticate()) {
                          EventTaxiImpl.singleton().fire(AuthenticatedEvent(AUTH_EVENT_TYPE.TRANSFER));
                        }
                      },
                    ),
                  ],
                ),
                // "CANCEL" button
                Row(
                  children: <Widget>[
                    AppButton(
                      type: AppButtonType.PrimaryOutline,
                      text: "CANCEL",
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> doTransfer({Currency fee}) async {
    fee = fee == null ? widget.fee : fee;
    try {
      showOverlay(context);
      RPCResponse result = await accountState
          .transferAccount(widget.publicKeyDisplay, fee: widget.fee);
      if (result.isError) {
        ErrorResponse errResp = result;
        UIUtil.showSnackbar(errResp.errorMessage, context);
        _overlay?.remove();
        Navigator.of(context).pop();
      } else {
        _overlay?.remove();
        try {
          OperationsResponse resp = result;
          PascalOperation op = resp.operations[0];
          if (op.valid == null || op.valid) {
            // Remove all traces of this account
            walletState.removeAccount(widget.account);
            Navigator.of(context)
                .popUntil(RouteUtils.withNameLike("/overview"));
            AppSheets.showBottomSheet(
                context: context,
                closeOnTap: true,
                widget: TransferredAccountSheet(
                  newAccountPubkey: widget.publicKeyDisplay,
                  fee: widget.fee,
                ));
          } else {
            if (op.errors.contains("zero fee") &&
                widget.fee == walletState.NO_FEE) {
              UIUtil.showFeeDialog(
                  context: context,
                  onConfirm: () async {
                    Navigator.of(context).pop();
                    doTransfer(fee: walletState.MIN_FEE);
                  });
            } else {
              UIUtil.showSnackbar("${op.errors}", context);
            }
          }
        } catch (e) {
          UIUtil.showSnackbar(
              "Something went wrong, try again later.", context);
        }
      }
    } catch (e) {
      _overlay?.remove();
      UIUtil.showSnackbar("Something went wrong, try again later.", context);
    }
  }

  Future<bool> authenticate() async {
    String message = "Authenticate to transfer account";
    // Authenticate
    AuthUtil authUtil = AuthUtil();
    if (await authUtil.useBiometrics()) {
      // Biometric auth
      bool authenticated = await authUtil.authenticateWithBiometrics(message);
      if (authenticated) {
        HapticUtil.fingerprintSucess();
      }
      return authenticated;
    } else {
      String expectedPin = await sl.get<Vault>().getPin();
      bool result = await Navigator.of(context).push(MaterialPageRoute<bool>(
          builder: (BuildContext context) {
        return PinScreen(
          type: PinOverlayType.ENTER_PIN,
          onSuccess: (pin) {
            Navigator.of(context).pop(true);
          },
          expectedPin: expectedPin,
          description:
              message,
        );
      }));
      await Future.delayed(Duration(milliseconds: 200));
      return result != null && result;
    }   
  }
}
