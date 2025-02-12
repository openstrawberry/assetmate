import 'dart:io';
import 'package:assetmate/button.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AutoAssetAdder(),
  ));
}

class AutoAssetAdder extends StatefulWidget {
  @override
  _AutoAssetAdderState createState() => _AutoAssetAdderState();
}

class _AutoAssetAdderState extends State<AutoAssetAdder> {
  bool isPressed = false;
  String? projectPath;
  String statusMessage = "Select a Flutter project folder to begin.";

  void pickProjectFolder() async {
    String? selectedPath = await FilePicker.platform.getDirectoryPath();
    if (selectedPath == null) return;

    if (!File('$selectedPath/pubspec.yaml').existsSync()) {
      setState(() {
        statusMessage =
            "Error: No pubspec.yaml found! Select a valid Flutter project.";
      });
      return;
    }

    setState(() {
      projectPath = selectedPath;
      statusMessage = "Project selected: $projectPath\nScanning for assets...";
    });

    processProject();
  }

  void processProject() {
    if (projectPath == null) return;

    String assetsPath = '$projectPath/assets';
    String pubspecPath = '$projectPath/pubspec.yaml';

    List<String> imagePaths = findImageFiles(assetsPath);

    if (imagePaths.isEmpty) {
      setState(() {
        statusMessage = "No new images found in assets folder.";
      });
      return;
    }

    updatePubspecYaml(pubspecPath, imagePaths);

    setState(() {
      statusMessage =
          "✅ pubspec.yaml updated successfully with ${imagePaths.length} images!";
    });
  }

  List<String> findImageFiles(String directoryPath) {
    Directory dir = Directory(directoryPath);
    List<String> allowedExtensions = [
      '.png',
      '.jpg',
      '.jpeg',
      '.gif',
      '.webp',
      '.svg'
    ];

    if (!dir.existsSync()) {
      return [];
    }

    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => allowedExtensions
            .any((ext) => file.path.toLowerCase().endsWith(ext)))
        .map((file) => file.path
            .replaceFirst(directoryPath + '/', '')) // Keep relative paths
        .toList();
  }

  void updatePubspecYaml(String pubspecPath, List<String> newAssets) {
    File file = File(pubspecPath);
    if (!file.existsSync()) return;

    String yamlContent = file.readAsStringSync();
    YamlEditor editor = YamlEditor(yamlContent);
    Map yamlData = loadYaml(yamlContent);

    List<String> existingAssets = extractExistingAssets(yamlData);
    List<String> updatedAssets = mergeAssetLists(existingAssets, newAssets);

    editor.update(['flutter', 'assets'], updatedAssets);
    file.writeAsStringSync(editor.toString());
  }

  List<String> extractExistingAssets(Map yamlData) {
    if (yamlData.containsKey('flutter') && yamlData['flutter'] is Map) {
      var flutterSection = yamlData['flutter'];
      if (flutterSection.containsKey('assets') &&
          flutterSection['assets'] is List) {
        return List<String>.from(flutterSection['assets']);
      }
    }
    return [];
  }

  List<String> mergeAssetLists(
      List<String> existingAssets, List<String> newAssets) {
    return {...existingAssets, ...newAssets}.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'AssetMate',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFAA32DB),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E3A8A).withOpacity(0.93),
            Color(0xFF1E3A8A).withOpacity(1),
          ],
          tileMode: TileMode.decal,
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Choose your project folder and it will add images directly to pubspec.yaml",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              projectPath == null ? '' : projectPath.toString(),
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            MouseRegion(
              onEnter: (_) {
                setState(() {
                  isPressed = true;
                });
              },
              onExit: (_) {
                setState(() {
                  isPressed = false;
                });
              },
              child: Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: GestureDetector(
                  onTap: pickProjectFolder,
                  child: Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          isPressed
                              ? BoxShadow(
                                  color: Color(0xFFAA32DB),
                                  blurRadius: 25,
                                  spreadRadius: 5)
                              : BoxShadow(),
                        ],
                        color: Color(0xFFAA32DB),
                        borderRadius:
                            BorderRadius.circular(isPressed ? 25 : 5)),
                    height: 50,
                    child: Center(
                        child: Text(
                      'Please Select Flutter Project Folder',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    )),
                  ),
                ),
              ),
            ),
            //ElevatedButton(onPressed: pickProjectFolder, child: Text("Select Flutter Project Folder"),),
            SizedBox(height: 20),
            Text(
              statusMessage,
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
