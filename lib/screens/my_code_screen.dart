import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wazni/models/user_model.dart';
import 'package:wazni/providers/user_provider.dart';
import 'package:wazni/services/firebase_service.dart';
import 'package:wazni/theme/app_theme.dart';

class MyCodeScreen extends StatefulWidget {
  const MyCodeScreen({super.key});

  @override
  State<MyCodeScreen> createState() => _MyCodeScreenState();
}

class _MyCodeScreenState extends State<MyCodeScreen> {
  bool _copied = false;

  Future<void> _copy(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<WazniUserProvider>().user;
    if (user == null) return const SizedBox();

    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          // Code card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Row(children: [
                  const Icon(Icons.share_rounded, color: WazniTheme.brand, size: 20),
                  const SizedBox(width: 8),
                  Text('كودك الشخصي', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15)),
                ]),
                const SizedBox(height: 6),
                Text('شاركيه مع صديقاتك ليتحدين معك',
                  style: GoogleFonts.tajawal(color: WazniTheme.inkMuted, fontSize: 13)),
                const SizedBox(height: 16),

                // Code display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: WazniTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: WazniTheme.border),
                  ),
                  child: Text(
                    user.code,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: WazniTheme.brand,
                      letterSpacing: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: () => _copy(user.code),
                  icon: Icon(_copied ? Icons.check_rounded : Icons.copy_rounded),
                  label: Text(_copied ? 'تم النسخ!' : 'نسخ الكود', style: GoogleFonts.tajawal()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _copied ? WazniTheme.green : WazniTheme.brand,
                  ),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 8),

          // Active challenges
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('تحدياتي النشطة', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                if (user.challenges.isEmpty)
                  Text('لا يوجد تحديات بعد', style: GoogleFonts.tajawal(color: WazniTheme.inkMuted))
                else
                  ...user.challenges.map((fUid) => _FriendTile(myUser: user, friendUid: fUid)),
              ]),
            ),
          ),

          const SizedBox(height: 16),

          // Footer
          Text('Wazni وزني · by erihdev',
            style: GoogleFonts.tajawal(color: WazniTheme.inkFaint, fontSize: 11)),
          const SizedBox(height: 20),
        ]),
      );
  }
}

class _FriendTile extends StatefulWidget {
  final WazniUser myUser;
  final String friendUid;
  const _FriendTile({required this.myUser, required this.friendUid});

  @override
  State<_FriendTile> createState() => _FriendTileState();
}

class _FriendTileState extends State<_FriendTile> {
  WazniUser? _friend;

  @override
  void initState() {
    super.initState();
    WazniFirebaseService.instance.getUser(widget.friendUid).then((u) {
      if (mounted) setState(() => _friend = u);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_friend == null) return const ListTile(leading: CircularProgressIndicator(strokeWidth: 2));
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: WazniTheme.brand.withValues(alpha: 0.12),
        child: Text(_friend!.initials, style: GoogleFonts.tajawal(color: WazniTheme.brand, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
      title: Text(_friend!.name, style: GoogleFonts.tajawal(fontWeight: FontWeight.w600)),
      trailing: TextButton(
        onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('إلغاء التحدي', style: GoogleFonts.tajawal()),
              content: Text('هل تريدين إلغاء التحدي مع ${_friend!.name}؟', style: GoogleFonts.tajawal()),
              actions: [
                TextButton(onPressed: ()=>Navigator.pop(context,false), child: Text('لا', style: GoogleFonts.tajawal())),
                TextButton(onPressed: ()=>Navigator.pop(context,true),  child: Text('نعم', style: GoogleFonts.tajawal(color: WazniTheme.red))),
              ],
            ),
          );
          if (ok==true && mounted) {
            await WazniFirebaseService.instance.removeChallenge(widget.myUser.uid, widget.friendUid);
            context.read<WazniUserProvider>().refresh();
          }
        },
        child: Text('إلغاء', style: GoogleFonts.tajawal(color: WazniTheme.red, fontSize: 12)),
      ),
    );
  }
}
