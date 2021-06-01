//
//  AudioFileWriteInfo.swift
//  
//
//  Created by 韦烽传 on 2021/5/28.
//

import Foundation
import AudioToolbox
import Print

/**
 音频文件写入信息
 */
open class AudioFileWriteInfo {
    
    /// 地址
    public let url: CFURL
    /// 文件句柄
    public let id: ExtAudioFileRef
    /// 音频参数
    public let basic: AudioStreamBasicDescription
    /// 输入音频参数
    open var client: AudioStreamBasicDescription?
    
    /**
     初始化
     
     - parameter    path:               文件路径
     - parameter    type:               文件类型
     - parameter    basicDescription:   写入音频参数
     - parameter    converter:          输入音频参数
     */
    public init?(_ path: String, type: AudioFileTypeID = kAudioFileCAFType, basicDescription: AudioStreamBasicDescription, converter: AudioStreamBasicDescription? = nil) {
        
        /// 地址
        url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, path as CFString, .cfurlposixPathStyle, false)
        
        /// 状态
        var status: OSStatus = noErr
        
        /// 文件句柄
        var file: ExtAudioFileRef?
        /// 文件标记
        let flags = AudioFileFlags.eraseFile
        /// 文件参数
        var description = basicDescription
        /// 创建音频文件（文件头4096长度）
        status = ExtAudioFileCreateWithURL(url, type, &description, nil, flags.rawValue, &file)
        Print.debug("ExtAudioFileCreateWithURL \(status)")
        guard status == noErr else { return nil }
        id = file!
        basic = description
        
        /// 设置客户端音频流参数（输入数据的参数）
        client = converter
        if client != nil {
            status = ExtAudioFileSetProperty(file!, kExtAudioFileProperty_ClientDataFormat, UInt32(MemoryLayout.stride(ofValue: client)), &client)
            Print.debug("kExtAudioFileProperty_ClientDataFormat \(status)")
            guard status == noErr else { return nil }
        }
    }
}
