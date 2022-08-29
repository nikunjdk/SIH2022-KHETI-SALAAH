// ignore_for_file: use_build_context_synchronously

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class ExcelUpload extends StatefulWidget {
  const ExcelUpload({Key? key}) : super(key: key);

  @override
  State<ExcelUpload> createState() => _ExcelUploadState();
}

class _ExcelUploadState extends State<ExcelUpload> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffb2db92),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Upload excel file containing number of farmers for bulk sms updates",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xbf000000),
                  fontSize: 21,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.08,
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 100),
              child: ElevatedButton(
                child: const Text("Upload File"),
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['xlsx'],
                  );

                  if (result != null) {
                    Dio dio = Dio();
                    dio.options.baseUrl =
                        'https://8e92-202-177-247-158.ngrok.io';
                    try {
                      File file = File(result.files.single.path!);
                      var formData = FormData.fromMap({
                        'uploadfile': await MultipartFile.fromFile(file.path)
                      });
                      Response response =
                          await dio.post('/api/v2/uploadfile', data: formData);
                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("File uploaded successfully"),
                          ),
                        );
                      }
                    } catch (e) {
                      print(e);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No file selected'),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
