//
//  ModelConfig.swift
//  SimpleChatbot
//
//  Created by Doniyorbek Ibrokhimov on 27/04/25.
//

import Foundation

struct Setup: Encodable {
    var setup: Setup
    
    struct Setup: Encodable {
        var model: String
        var generationConfig: GenerationConfig
        var systemInstruction: Content
    }
    
    init(model: String, generationConfig: GenerationConfig, systemInstruction: Content) {
        self.setup = .init(model: model, generationConfig: generationConfig, systemInstruction: systemInstruction)
    }
    
    struct GenerationConfig: Encodable {
        
        /*
         {
         "stopSequences": [
         string
         ],
         "responseMimeType": string,
         "responseSchema": {
         object (Schema)
         },
         "responseModalities": [
         enum (Modality)
         ],
         "candidateCount": integer,
         "maxOutputTokens": integer,
         "temperature": number,
         "topP": number,
         "topK": integer,
         "seed": integer,
         "presencePenalty": number,
         "frequencyPenalty": number,
         "responseLogprobs": boolean,
         "logprobs": integer,
         "enableEnhancedCivicAnswers": boolean,
         "speechConfig": {
         object (SpeechConfig)
         },
         "thinkingConfig": {
         object (ThinkingConfig)
         },
         "mediaResolution": enum (MediaResolution)
         }
         */
        
        let responseModalities: [Modality]
        let speechConfig: SpeechConfig
        
        enum Modality: String, RawRepresentable, Codable {
            case audio = "AUDIO"
        }
        
        struct SpeechConfig: Encodable {
            /*
             {
             "voiceConfig": {
             object (VoiceConfig)
             },
             "languageCode": string
             }
             */
            
            let voiceConfig: VoiceConfig
            let languageCode: String
            
            struct VoiceConfig: Encodable {
                
                /*
                 {
                 
                 // voice_config
                 "prebuiltVoiceConfig": {
                 object (PrebuiltVoiceConfig)
                 }
                 // Union type
                 }
                 */
                let prebuiltVoiceConfig: PrebuiltVoiceConfig
                
                struct PrebuiltVoiceConfig: Encodable {
                    /*
                     {
                       "voiceName": string
                     }
                     */
                    let voiceName: String
                }
            }
        }
    }
    
    struct Content: Encodable {
        let parts: [Part]
        let role: String
        
        struct Part: Encodable {
            let thought: Bool
            let text: String
        }
    }
}




