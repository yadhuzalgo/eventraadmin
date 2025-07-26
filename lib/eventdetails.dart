import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';


class Evd extends StatefulWidget {
  const Evd({super.key});

  @override
  State<Evd> createState() => _EvdState();
}

class _EvdState extends State<Evd> {
  final CollectionReference bookingsCollection =
  FirebaseFirestore.instance.collection("bookings");

  void updateStatus(String docId, String status) async {
    try {
      await bookingsCollection.doc(docId).update({'status': status});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking $status")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error updating status")),
      );
    }
  }

  Widget statusChip(String status) {
    Color color;
    switch (status) {
      case 'Approved':
        color = Colors.green;
        break;
      case 'Declined':
        color = Colors.redAccent;
        break;
      default:
        color = Colors.orange;
    }

    return Chip(
      label: Text(status, style:  TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar:  AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 80,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRRect(
        borderRadius:  BorderRadius.vertical(
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
              borderRadius:  BorderRadius.vertical(
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
           SizedBox(width: 10),
          Text(
            "Booking Details",
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


    body: StreamBuilder<QuerySnapshot>(
        stream:
        bookingsCollection.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return  Center(child: Text('Error loading bookings'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return  Center(child: Text('No bookings found'));
          }

          return ListView.builder(
            padding:  EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final data = booking.data() as Map<String, dynamic>;

              DateTime? parsedDate;
              try {
                if (data['date'] != null && data['date'].isNotEmpty) {
                  parsedDate = DateFormat('d/M/yyyy').parse(data['date']);
                }
              } catch (e) {
                print('Error parsing date: ${data['date']}');
              }

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                margin:  EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding:  EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading:  Icon(Icons.event_note, color: Colors.deepPurple),
                        title: Text(
                          data['package'] ?? '',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             SizedBox(height: 4),
                            Text("Stage: ${data['stage'] ?? '-'}",
                                style: GoogleFonts.poppins()),
                            Text("Price: ₹${data['price'] ?? '-'}",
                                style: GoogleFonts.poppins()),
                            if (parsedDate != null)
                              Text(
                                "Date: ${DateFormat('dd MMM yyyy').format(parsedDate)}",
                                style: GoogleFonts.poppins(),
                              ),
                             SizedBox(height: 6),
                            Row(
                              children: [
                                 Text("Status: ",
                                    style: TextStyle(fontWeight: FontWeight.w500)),
                                statusChip(data['status'] ?? 'Pending'),
                              ],
                            ),
                          ],
                        ),
                      ),
                       SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding:  EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon:  Icon(Icons.check, size: 18),
                            label:  Text("Approve"),
                            onPressed: () =>
                                updateStatus(booking.id, 'Approved'),
                          ),
                           SizedBox(width: 10),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding:  EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon:  Icon(Icons.close, size: 18),
                            label:  Text("Decline"),
                            onPressed: () =>
                                updateStatus(booking.id, 'Declined'),
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
