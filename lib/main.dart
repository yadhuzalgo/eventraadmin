import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:projectflutteradmin/adminlogin.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: Adlog()));
}

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final name = TextEditingController();
  final about = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();

  final firestore = FirebaseFirestore.instance.collection("pass");
  String companyImageUrl = '';
  List<Map<String, dynamic>> stageImages = [];
  List<Map<String, TextEditingController>> packages = [
    {'name': TextEditingController(), 'price': TextEditingController()}
  ];

  Future uploadImage(File file, {bool isStage = false}) async {
    final path = isStage ? 'image/stage_' : 'image/';
    final ref = FirebaseStorage.instance
        .ref()
        .child('$path${DateTime.now().millisecondsSinceEpoch}');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future submitData() async {
    if (name.text.isEmpty ||
        about.text.isEmpty ||
        phone.text.length != 10 ||
        email.text.isEmpty ||

        companyImageUrl.isEmpty ||
        stageImages.isEmpty) {
      showMsg("Please fill all fields");
      return;
    }

    final packData = packages
        .map((p) => {
      'name': p['name']!.text,
      'price': p['price']!.text,
    })
        .toList();

    final data = {
      'name': name.text,
      'about': about.text,

      'number': phone.text,
      'email': email.text,
      'image': companyImageUrl,
      'stageImages': stageImages,
      'packages': packData,
    };

    try {
      await firestore.add(data);
      showMsg("Data uploaded");
      resetForm();
    } catch (e) {
      showMsg("Error: $e");
    }
  }

  void resetForm() {
    name.clear();
    about.clear();
    phone.clear();
    email.clear();
    companyImageUrl = '';
    stageImages.clear();
    packages = [
      {'name': TextEditingController(), 'price': TextEditingController()}
    ];
    setState(() {});
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget textField(String label, TextEditingController ctrl,
      {TextInputType inputType = TextInputType.text, int? maxLength}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: ctrl,
        keyboardType: inputType,
        inputFormatters: maxLength != null
            ? [
          LengthLimitingTextInputFormatter(maxLength),
          FilteringTextInputFormatter.digitsOnly,
        ]
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }



  Widget imagePreview(String url) => Padding(
    padding: const EdgeInsets.all(8),
    child: Image.network(url, height: 100),
  );

  Future   pickStageImages() async {
    final images = await ImagePicker().pickMultiImage();
    for (var img in images) {
      final url = await uploadImage(File(img.path), isStage: true);
      final nameCtrl = TextEditingController();
      final stageName = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Stage Name"),
          content: TextField(controller: nameCtrl),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(onPressed: () => Navigator.pop(context, nameCtrl.text), child: Text("OK")),
          ],
        ),
      );
      if (stageName != null && stageName.isNotEmpty) {
        stageImages.add({'url': url, 'stageName': stageName});
        setState(() {});
      }
    }
  }

  Widget sectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(
      title,
      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
    ),
  );

  Widget cardContainer(List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: children,
    ),
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(28),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0F2027),
                    Color(0xFF2C5364),
                    Color(0xFF203A43),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.cyanAccent.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
            Text(
              "Admin",
              style: GoogleFonts.orbitron( // Futuristic font
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle("Company Details"),
            cardContainer([
              textField("Company Name", name),
              textField("About", about),
              textField("Phone", phone, inputType: TextInputType.phone, maxLength: 10),
              textField("Email", email, inputType: TextInputType.emailAddress),
            ]),

            const SizedBox(height: 20),
            sectionTitle("Packages"),
            ...packages.map((p) => cardContainer([
              Row(
                children: [
                  Expanded(child: textField("Package", p['name']!)),
                  const SizedBox(width: 10),
                  Expanded(child: textField("Price", p['price']!, inputType: TextInputType.number)),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        packages.remove(p);
                      });
                    },
                  ),
                ],
              ),
            ])).toList(),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add Package"),
                onPressed: () {
                  setState(() {
                    packages.add({'name': TextEditingController(), 'price': TextEditingController()});
                  });
                },
              ),
            ),

            const SizedBox(height: 20),
            sectionTitle("Company Image"),
            cardContainer([
              ElevatedButton.icon(
                icon: const Icon(Icons.upload),
                label: const Text("Upload Company Image"),
                onPressed: () async {
                  final img = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (img != null) companyImageUrl = await uploadImage(File(img.path));
                  setState(() {});
                },
              ),
              if (companyImageUrl.isNotEmpty) imagePreview(companyImageUrl),
            ]),

            const SizedBox(height: 20),
            sectionTitle("Stage Images"),
            cardContainer([
              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text("Upload Stage Images"),
                onPressed: pickStageImages,
              ),
              const SizedBox(height: 10),
              if (stageImages.isNotEmpty)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: stageImages.map((e) {
                    return Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(e['url'], height: 100, width: 100, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 4),
                        Text(e['stageName'], style: GoogleFonts.poppins(fontSize: 13)),
                      ],
                    );
                  }).toList(),
                ),
            ]),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text("Submit Data"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: submitData,
              ),
            )
          ],
        ),
      ),

    );
  }
}
