//
//  AudioFileReadInfo.swift
//  
//
//  Created by 韦烽传 on 2021/5/28.
//

import Foundation
import AudioToolbox
import Print

/**
 音频文件读取信息
 */
open class AudioFileReadInfo {
    
    /// 地址
    public let url: CFURL
    /// 文件句柄
    public let id: ExtAudioFileRef
    /// 音频参数
    public let basic: AudioStreamBasicDescription
    /// 输出音频参数
    open var client: AudioStreamBasicDescription?
    /// 帧数
    public let frames: Int64
    /// 时长
    public let duration: Double
    
    /**
     初始化
     
     - parameter    path:       文件路径
     - parameter    converter:  输出音频参数
     */
    public init?(_ path: String, converter: AudioStreamBasicDescription? = nil) {
        
        /// 地址
        url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, path as CFString, .cfurlposixPathStyle, false)
        
        /// 状态
        var status: OSStatus = noErr
        
        /// 获取文件句柄
        var file: ExtAudioFileRef?
        status = ExtAudioFileOpenURL(url, &file)
        Print.debug("ExtAudioFileOpenURL \(status)")
        guard status == noErr else { return nil }
        id = file!
        
        /// 获取文件音频流参数
        var description = AudioStreamBasicDescription()
        var size = UInt32(MemoryLayout.stride(ofValue: description))
        status = ExtAudioFileGetProperty(file!, kExtAudioFileProperty_FileDataFormat, &size, &description)
        Print.debug("kExtAudioFileProperty_FileDataFormat \(status)")
        guard status == noErr else { return nil }
        basic = description
        
        /// 获取文件音频流帧数
        var numbersFrames: Int64 = 0
        var numbersFramesSize = UInt32(MemoryLayout.stride(ofValue: numbersFrames))
        status = ExtAudioFileGetProperty(file!, kExtAudioFileProperty_FileLengthFrames, &numbersFramesSize, &numbersFrames)
        Print.debug("kExtAudioFileProperty_FileLengthFrames \(status)")
        guard status == noErr else { return nil }
        frames = numbersFrames
        
        /// 时长
        duration = Float64(frames)/basic.mSampleRate
        
        /// 设置客户端音频流参数（输出数据参数）
        client = converter
        if client != nil {
            status = ExtAudioFileSetProperty(file!, kExtAudioFileProperty_ClientDataFormat, UInt32(MemoryLayout.stride(ofValue: client)), &client)
            Print.debug("kExtAudioFileProperty_ClientDataFormat \(status)")
            guard status == noErr else { return nil }
        }
    }
}
