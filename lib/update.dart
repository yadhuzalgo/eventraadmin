import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';


class Upd extends StatefulWidget {
  const Upd({super.key});

  @override
  State<Upd> createState() => _UpdState();
}

class _UpdState extends State<Upd> {
  final CollectionReference items = FirebaseFirestore.instance.collection("pass");

  void showEditDialog(DocumentSnapshot doc) {
    TextEditingController nameController = TextEditingController(text: doc['name']);
    TextEditingController phoneController = TextEditingController(text: doc['number']);
    TextEditingController emailController = TextEditingController(text: doc['email']);
    TextEditingController aboutController = TextEditingController(text: doc['about']);

    List<Map<String, TextEditingController>> packageControllers = [];

    if (doc['packages'] is List) {
      for (var p in doc['packages']) {
        packageControllers.add({
          'name': TextEditingController(text: p['name']),
          'price': TextEditingController(text: p['price']),
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Edit Details", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Company Name"),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Packages", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          packageControllers.add({
                            'name': TextEditingController(),
                            'price': TextEditingController(),
                          });
                        });
                      },
                    )
                  ],
                ),
                const SizedBox(height: 8),
                ...packageControllers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final controllers = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controllers['name'],
                            decoration: InputDecoration(labelText: "Package ${index + 1}"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: controllers['price'],
                            decoration: const InputDecoration(labelText: "Price"),
                          ),
                        ),
                        if (packageControllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                packageControllers.removeAt(index);
                              });
                            },
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),

                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone"),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: aboutController,
                  decoration: const InputDecoration(labelText: "About"),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                final updatedPackages = packageControllers.map((pc) {
                  return {
                    'name': pc['name']!.text,
                    'price': pc['price']!.text,
                  };
                }).toList();

                await items.doc(doc.id).update({
                  'name': nameController.text,
                  'packages': updatedPackages,
                  'number': phoneController.text,
                  'email': emailController.text,
                  'about': aboutController.text,
                });
                Navigator.pop(context);
              },
              icon: Icon(Icons.check, color: Colors.green),
              label: Text("Update", style: TextStyle(color: Colors.green)),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close, color: Colors.red),
              label: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      }),
    );
  }

  void deleteItem(String id) async {
    await items.doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Deleted successfully")),
    );
  }

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
              "Update",
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
      body: StreamBuilder(
        stream: items.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error loading data"));
          if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs;

          if (data.isEmpty) return const Center(child: Text("No data found"));

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final doc = data[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc['name'], style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      if (doc.data().toString().contains('packages'))
                        if (doc['packages'] is List)
                          ...List.from(doc['packages']).map((pkg) {
                            if (pkg is Map) {
                              return Text(
                                "📦 ${pkg['name']} - ₹${pkg['price']}",
                                style: GoogleFonts.poppins(fontSize: 14),
                              );
                            } else {
                              return const Text("Invalid package data");
                            }
                          }),
                      const SizedBox(height: 6),
                      Text("📞 Phone: ${doc['number']}", style: GoogleFonts.poppins(fontSize: 14)),
                      Text("📧 Email: ${doc['email']}", style: GoogleFonts.poppins(fontSize: 14)),
                      Text("ℹ️ About: ${doc['about']}", style: GoogleFonts.poppins(fontSize: 14)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => showEditDialog(doc),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteItem(doc.id),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
