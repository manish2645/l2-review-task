import 'package:dio/dio.dart' show Dio, DioError;
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart' show DownloadsPathProvider;
import 'package:flutter/material.dart' show AppBar, BuildContext, Color, Column, Container, Divider, EdgeInsets, ElevatedButton, LinearProgressIndicator, Padding, Scaffold, SizedBox, State, StatefulWidget, Text, Widget;
import 'package:permission_handler/permission_handler.dart' show Permission, PermissionListActions, PermissionStatus, PermissionStatusGetters;

class FileDownloader extends StatefulWidget {
  @override
  _FileDownloaderState createState() => _FileDownloaderState();
}

class _FileDownloaderState extends State<FileDownloader> {
  String fileUrl =
      "https://www3.stats.govt.nz/2018census/8317_Age%20and%20sex%20by%20ethnic%20group%20(grouped%20total%20responses),%20for%20census%20night%20population%20counts,%202006,%202013,%20and%202018%20Censuses%20(RC,%20TA,%20SA2,%20DHB).zip?_ga=2.100955777.1276295418.1689246800-834889731.1689246800";
  bool downloading = false;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Download File"),
        backgroundColor: const Color.fromARGB(255, 52, 123, 216),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 50),
        child: Column(
          children: [
            Text("File URL: $fileUrl"),
            const Divider(),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  downloading = true;
                  progress = 0;
                });

                Map<Permission, PermissionStatus> statuses = await [
                  Permission.storage,
                ].request();

                if (statuses[Permission.storage]!.isGranted) {
                  var dir = await DownloadsPathProvider.downloadsDirectory;
                  if (dir != null) {
                    String saveName = "file.zip";
                    String savePath = dir.path + "/$saveName";
                    print(savePath);

                    try {
                      await Dio().download(
                        fileUrl,
                        savePath,
                        onReceiveProgress: (received, total) {
                          if (total != -1) {
                            double percentage = (received / total * 100);
                            setState(() {
                              progress = percentage;
                            });
                            print("$percentage%");
                          }
                        },
                      );
                      print("File is saved to the download folder.");
                    // ignore: deprecated_member_use
                    } on DioError catch (e) {
                      print(e.message);
                    } finally {
                      setState(() {
                        downloading = false;
                      });
                    }
                  }
                } else {
                  print("No permission to read and write.");
                }
              },
              child: const Text("Download File"),
            ),
            if (downloading)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    LinearProgressIndicator(value: progress / 100),
                    const SizedBox(height: 10),
                    Text("${progress.toStringAsFixed(0)}%"),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
