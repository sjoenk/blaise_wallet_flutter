import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:blaise_wallet_flutter/appstate_container.dart';
import 'package:blaise_wallet_flutter/localization.dart';
import 'package:blaise_wallet_flutter/ui/util/app_icons.dart';
import 'package:blaise_wallet_flutter/ui/util/text_styles.dart';
import 'package:blaise_wallet_flutter/ui/widgets/buttons.dart';
import 'package:blaise_wallet_flutter/util/ui_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EncryptedPrivateKeySheet extends StatefulWidget {
  final String encryptedKey;

  EncryptedPrivateKeySheet({this.encryptedKey});

  _EncryptedPrivateKeySheetState createState() =>
      _EncryptedPrivateKeySheetState();
}

class _EncryptedPrivateKeySheetState extends State<EncryptedPrivateKeySheet> {
  bool _keyCopied;
  bool _showingKey;
  Timer _keyCopiedTimer;

  @override
  void initState() {
    super.initState();
    _keyCopied = false;
    _showingKey = false;
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
                          toUppercase(AppLocalization.of(context)
                              .privateKeySheetHeader
                              ,context),
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
                        margin: EdgeInsetsDirectional.fromSTEB(30, 30, 30, 0),
                        child: AutoSizeText.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: AppLocalization.of(context)
                                        .backupEncryptedKeyFirstParagraph +
                                    "\n\n",
                                style: AppStyles.paragraph(context),
                              ),
                              TextSpan(
                                text: AppLocalization.of(context)
                                    .backupEncryptedKeySecondParagraph,
                                style: AppStyles.paragraphPrimary(context),
                              ),
                            ],
                          ),
                          stepGranularity: 0.5,
                          maxLines: 10,
                          minFontSize: 8,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      // Container for the private key
                      Container(
                        margin: EdgeInsetsDirectional.fromSTEB(30, 24, 30, 0),
                        padding: EdgeInsetsDirectional.fromSTEB(24, 12, 24, 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              width: 1,
                              color: StateContainer.of(context)
                                  .curTheme
                                  .primary15),
                          color: StateContainer.of(context).curTheme.primary10,
                        ),
                        child: AutoSizeText(
                          _showingKey
                              ? widget.encryptedKey
                              : '•' * widget.encryptedKey.length,
                          maxLines: 4,
                          stepGranularity: 0.1,
                          minFontSize: 8,
                          textAlign: TextAlign.center,
                          style: AppStyles.privateKeyPrimary(context),
                        ),
                      ),
                      // Container for the Show/Hide button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.0),
                              color: StateContainer.of(context)
                                  .curTheme
                                  .backgroundPrimary,
                              boxShadow: [
                                StateContainer.of(context)
                                    .curTheme
                                    .shadowTextDark,
                              ],
                            ),
                            margin:
                                EdgeInsetsDirectional.fromSTEB(30, 12, 30, 0),
                            height: 40,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100.0)),
                              child: AutoSizeText(
                                _showingKey
                                    ? AppLocalization.of(context).hideButton
                                    : AppLocalization.of(context).showButton,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                stepGranularity: 0.1,
                                style: AppStyles.buttonMiniBg(context),
                              ),
                              onPressed: () {
                                setState(() {
                                  _showingKey = !_showingKey;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                //"Copy Encrypted Key" and "Close" buttons
                Row(
                  children: <Widget>[
                    AppButton(
                      type: _keyCopied
                          ? AppButtonType.Success
                          : AppButtonType.Primary,
                      text: _keyCopied
                          ? AppLocalization.of(context).keyCopiedButton
                          : AppLocalization.of(context).copyEncryptedKeyButton,
                      buttonTop: true,
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: widget.encryptedKey));
                        setState(() {
                          _keyCopied = true;
                        });
                        if (_keyCopiedTimer != null) {
                          _keyCopiedTimer.cancel();
                        }
                        _keyCopiedTimer =
                            Timer(const Duration(milliseconds: 1500), () {
                          if (mounted) {
                            setState(() {
                              _keyCopied = false;
                            });
                          }
                        });
                      },
                    ),
                  ],
                ),
                // "Close" button
                Row(
                  children: <Widget>[
                    AppButton(
                      type: AppButtonType.PrimaryOutline,
                      text: AppLocalization.of(context).closeButton,
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
}
