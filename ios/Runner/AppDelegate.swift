import Flutter
import UIKit
import MobileCoreServices

public class AppDelegate: FlutterAppDelegate {
    private let CHANNEL = "file_picker"
    private let FILE_HANDLE_CHANNEL = "file_handler"
    private var pendingFileUrl: URL?
    private var result: FlutterResult?
    
    override public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        
        let filePickerChannel = FlutterMethodChannel(
            name: CHANNEL,
            binaryMessenger: controller.binaryMessenger
        )
        filePickerChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "pickFile" {
                self?.result = result
                self?.openFilePicker(controller: controller)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        
        let fileHandlerChannel = FlutterMethodChannel(
            name: FILE_HANDLE_CHANNEL,
            binaryMessenger: controller.binaryMessenger
        )
        fileHandlerChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "getOpenedFile" {
                if let fileUrl = self?.pendingFileUrl {
                    self?.processFile(fileUrl: fileUrl, result: result)
                    self?.pendingFileUrl = nil
                } else {
                    result(nil)
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        
        if let url = launchOptions?[.url] as? URL {
            pendingFileUrl = url
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override public func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        pendingFileUrl = url
        handleFileUrl(url: url)
        return true
    }
    
    private func openFilePicker(controller: FlutterViewController) {
        let documentPicker = UIDocumentPickerViewController(
            documentTypes: [String(kUTTypeData), String(kUTTypeContent), String(kUTTypeItem)],
            in: .import
        )
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        controller.present(documentPicker, animated: true)
    }
    
    private func handleFileUrl(url: URL) {
        let fileType = determineFileType(url: url)
        
        if fileType != "unknown" {
            let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
            let fileHandlerChannel = FlutterMethodChannel(
                name: FILE_HANDLE_CHANNEL,
                binaryMessenger: controller.binaryMessenger
            )
            
            fileHandlerChannel.invokeMethod("showImportDialog", arguments: [
                "uri": url.absoluteString,
                "type": fileType
            ])
        }
    }
    
    private func determineFileType(url: URL) -> String {
        let path = url.absoluteString.lowercased()
        let fileName = url.lastPathComponent.lowercased()
        
        if path.contains(".character") || fileName.hasSuffix(".character") {
            return "character"
        } else if path.contains(".race") || fileName.hasSuffix(".race") {
            return "race"
        } else if path.contains(".chax") || fileName.hasSuffix(".chax") {
            return "chax"
        } else if path.contains(".note") || fileName.hasSuffix(".note") {
            return "note"
        } else if path.contains(".characterbook") || fileName.hasSuffix(".characterbook") {
            return "characterbook"
        }
        else {
            return "unknown"
        }
    }
    
    private func processFile(fileUrl: URL, result: @escaping FlutterResult) {
        do {
            let originalName = fileUrl.lastPathComponent
            let filePath = try copyFileToCache(fileUrl: fileUrl, fileName: originalName)
            
            let fileType = determineFileType(url: fileUrl)
            
            let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
            let fileHandlerChannel = FlutterMethodChannel(
                name: FILE_HANDLE_CHANNEL,
                binaryMessenger: controller.binaryMessenger
            )
            
            fileHandlerChannel.invokeMethod("onFileOpened", arguments: [
                "path": filePath,
                "type": fileType,
                "originalName": originalName
            ])
            
            result(filePath)
        } catch {
            result(FlutterError(
                code: "FILE_ERROR",
                message: "Error processing file: \(error.localizedDescription)",
                details: nil
            ))
        }
    }
    
    private func copyFileToCache(fileUrl: URL, fileName: String) throws -> String {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let destinationUrl = cacheDir.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            try FileManager.default.removeItem(at: destinationUrl)
        }
        
        try FileManager.default.copyItem(at: fileUrl, to: destinationUrl)
        return destinationUrl.path
    }
}

extension AppDelegate: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            result?(FlutterError(code: "NO_FILE", message: "No file selected", details: nil))
            result = nil
            return
        }
        
        guard url.startAccessingSecurityScopedResource() else {
            result?(FlutterError(code: "ACCESS_DENIED", message: "Could not access file", details: nil))
            result = nil
            return
        }
        
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let filePath = try copyFileToCache(fileUrl: url, fileName: url.lastPathComponent)
            result?(filePath)
        } catch {
            result?(FlutterError(
                code: "COPY_FAILED",
                message: "Failed to copy file: \(error.localizedDescription)",
                details: nil
            ))
        }
        
        result = nil
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        result?(FlutterError(code: "CANCELLED", message: "File picking cancelled", details: nil))
        result = nil
    }
}