//
//  ViewController.swift
//  URLSessionTest
//
//  Created by Andrew Konovalskiy on 04.04.17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - IBOulets
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var progressLabel: UILabel!
    
    // MARK: - Properties
    // Put here your link on pdf document
    fileprivate let url: URL = URL(string: "http://scholar.princeton.edu/sites/default/files/oversize_pdf_test_0.pdf")!
    
    fileprivate var downloadTask: URLSessionDownloadTask?
    fileprivate var backgroundSession: URLSession?
    
    // MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        backgroundSession = URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        progressView.setProgress(0.0, animated: false)
    }
}

// MARK - IBActions
extension ViewController {
    
    @IBAction func startDownload(_ sender: UIButton) {
        
        guard downloadTask?.state != .running  else { return }
        downloadTask = nil
        downloadTask = backgroundSession?.downloadTask(with: url)
        downloadTask?.resume()
    }
    
    @IBAction func pause(_ sender: UIButton) {
        
        downloadTask?.suspend()
    }
    
    @IBAction func resume(_ sender: UIButton) {
        
        downloadTask?.resume()
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        
        downloadTask?.cancel()
        downloadTask = nil
        progressView.setProgress(0.0, animated: true)
        progressLabel.text = "Downloaded kb's: \n"
    }
}

// MARK: - URLSessionDownloadDelegate
extension ViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL){
        
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectoryPath:String = path[0]
        let fileManager = FileManager()
        let destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath.appendingFormat("/file.pdf"))
        
        if fileManager.fileExists(atPath: destinationURLForFile.path){
            showFileWithPath(path: destinationURLForFile.path)
        }
        else {
            do {
                try fileManager.moveItem(at: location, to: destinationURLForFile)
                
                showFileWithPath(path: destinationURLForFile.path)
            } catch {
                print("An error occurred while moving file to destination url")
            }
        }
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64){
        
        progressView.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
        progressLabel.text = "Downloaded kb's: \n" + String(round(Float(totalBytesWritten)) / 1024)
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        
        downloadTask = nil
        progressView.setProgress(0.0, animated: true)
        if (error != nil) {
            print(error!.localizedDescription)
        } else {
            print("Task was finished")
        }
    }
}

// MARK: - Show PDF doc
extension ViewController: UIDocumentInteractionControllerDelegate {
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController
    {
        return self
    }
    
    fileprivate func showFileWithPath(path: String){
        let isFileFound: Bool? = FileManager.default.fileExists(atPath: path)
        if isFileFound == true {
            let viewer = UIDocumentInteractionController(url: URL(fileURLWithPath: path))
            viewer.delegate = self
            viewer.presentPreview(animated: true)
        }
    }
}
