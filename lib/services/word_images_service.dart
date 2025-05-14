// word_document_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';

class WordImagesService {
  static Future<File> createWordDocument(List<File> imageFiles) async {
    final archive = Archive();

    // Add content types
    archive.addFile(ArchiveFile(
        '[Content_Types].xml',
        _getContentTypesXml(imageFiles.length).length,
        utf8.encode(_getContentTypesXml(imageFiles.length))));

    // Add package relationships
    archive.addFile(ArchiveFile('_rels/.rels', _getRelationshipsXml().length,
        utf8.encode(_getRelationshipsXml())));

    // Add document relationships
    final docRelsXml = _getDocumentRelationshipsXml(imageFiles.length);
    archive.addFile(ArchiveFile('word/_rels/document.xml.rels',
        docRelsXml.length, utf8.encode(docRelsXml)));

    // Add media files
    for (int i = 0; i < imageFiles.length; i++) {
      final imageBytes = await imageFiles[i].readAsBytes();
      final ext = _getImageExtension(imageFiles[i].path);
      archive.addFile(ArchiveFile(
          'word/media/image${i + 1}.$ext', imageBytes.length, imageBytes));
    }

    // Add main document content
    final docXml = _generateWordDocumentXml(imageFiles.length);
    archive.addFile(
        ArchiveFile('word/document.xml', docXml.length, utf8.encode(docXml)));

    // Add styles
    final stylesXml = _getStylesXml();
    archive.addFile(ArchiveFile(
        'word/styles.xml', stylesXml.length, utf8.encode(stylesXml)));

    // Encode to ZIP
    final zipData = ZipEncoder().encode(archive);
    if (zipData == null) {
      throw Exception("Failed to create ZIP archive");
    }

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/document_$timestamp.docx';

    return File(filePath)..writeAsBytes(zipData);
  }

  static String _getImageExtension(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ext == 'jpg' ? 'jpeg' : ext;
  }

  static String _generateWordDocumentXml(int imageCount) {
    final imageElements = StringBuffer();
    for (int i = 1; i <= imageCount; i++) {
      imageElements.write('''
    <w:p>
      <w:r>
        <w:drawing>
          <wp:inline distT="0" distB="0" distL="0" distR="0">
            <wp:extent cx="5000000" cy="3000000"/>
            <wp:effectExtent l="0" t="0" r="0" b="0"/>
            <wp:docPr id="$i" name="Picture $i"/>
            <wp:cNvGraphicFramePr>
              <a:graphicFrameLocks xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" noChangeAspect="1"/>
            </wp:cNvGraphicFramePr>
            <a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
              <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
                <pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
                  <pic:nvPicPr>
                    <pic:cNvPr id="0" name="Picture $i"/>
                    <pic:cNvPicPr/>
                  </pic:nvPicPr>
                  <pic:blipFill>
                    <a:blip r:embed="rId$i"/>
                    <a:stretch>
                      <a:fillRect/>
                    </a:stretch>
                  </pic:blipFill>
                  <pic:spPr>
                    <a:xfrm>
                      <a:off x="0" y="0"/>
                      <a:ext cx="5000000" cy="3000000"/>
                    </a:xfrm>
                    <a:prstGeom prst="rect">
                      <a:avLst/>
                    </a:prstGeom>
                  </pic:spPr>
                </pic:pic>
              </a:graphicData>
            </a:graphic>
          </wp:inline>
        </w:drawing>
      </w:r>
    </w:p>
    <w:p>
      <w:r>
        <w:br/> <!-- Line break -->
        <w:spacing w:before="240" w:after="240"/> <!-- Add space after image -->
      </w:r>
    </w:p>
    ''');
    }

    return '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
            xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
            xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <w:body>
    $imageElements
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>
      <w:cols w:space="720"/>
      <w:docGrid w:linePitch="360"/>
    </w:sectPr>
  </w:body>
</w:document>''';
  }

  static String _getContentTypesXml(int imageCount) {
    final imageTypes = StringBuffer();
    for (int i = 1; i <= imageCount; i++) {
      imageTypes.write('''
      <Default Extension="jpeg" ContentType="image/jpeg"/>
  <Default Extension="png" ContentType="image/png"/>
  ''');
    }

    return '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  $imageTypes
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>''';
  }

  static String _getRelationshipsXml() {
    return '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>''';
  }

  static String _getDocumentRelationshipsXml(int imageCount) {
    final relationships = StringBuffer();
    for (int i = 1; i <= imageCount; i++) {
      relationships.write('''
  <Relationship Id="rId$i" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/image$i.jpeg"/>
  ''');
    }

    return '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
$relationships
</Relationships>''';
  }

  static String _getStylesXml() {
    return '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault>
      <w:rPr>
        <w:sz w:val="24"/>
        <w:szCs w:val="24"/>
      </w:rPr>
    </w:rPrDefault>
  </w:docDefaults>
</w:styles>''';
  }
}