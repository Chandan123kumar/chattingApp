import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class DynamicLinkScreen extends StatefulWidget {
  const DynamicLinkScreen({super.key});

  @override
  State<DynamicLinkScreen> createState() => _DynamicLinkScreenState();
}

class _DynamicLinkScreenState extends State<DynamicLinkScreen> {



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          ElevatedButton(onPressed: () async{
            var text = await generateDynamicLink();
            Share.share(text.toString());
          }, child: Text("Generate Link"))
        ],
      ),
    );
  }
  
 Future<Uri> generateDynamicLink()async{
   var shortLink =await FirebaseDynamicLinks.instance.buildShortLink(DynamicLinkParameters(
        link: Uri.parse("https://rdynamiclinkappr.page.link"),
        uriPrefix: "https://rdynamiclinkappr.page.link",
        androidParameters: const AndroidParameters(packageName: "com.communication.talktogether"),
    ),);

   return shortLink.shortUrl;
  }
}
