import Foundation

class SerpAPIService {
    let apiKey = "f2e22ca29699b84b620ea3102fa336d3058157f447dc39fa6e7c7a617a9be53d"
  
    func fetchYouTubeVideo(for mood: String, completion: @escaping (String?) -> Void) {
        // Prepare the query URL with the correct 'search_query' parameter
        let query = "Making user mood good from current user mood of: \(mood), mood uplifting videos"
        let urlString = "https://serpapi.com/search.json?search_query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&engine=youtube&api_key=\(apiKey)"
        
        print("SerpAPI Request URL: \(urlString)") // Debug: Show the request URL
        
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL.")
            completion(nil)
            return
        }
        
        // Perform the request
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: Network request failed with error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("Error: No data received from the server.")
                completion(nil)
                return
            }
            
            do {
                // Parse the JSON response
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("SerpAPI JSON Response: \(json)")
                    
                    var videoResults: [[String: Any]]? = nil
                    
                    // Try "video_results" first
                    if let videos = json["video_results"] as? [[String: Any]] {
                        videoResults = videos
                        print("Extracted Videos from 'video_results': \(videos)")
                    }
                    
                    // Fallback: Try "videos" key if needed
                    if videoResults == nil, let videos = json["videos"] as? [[String: Any]] {
                        videoResults = videos
                        print("Extracted Videos from 'videos': \(videos)")
                    }
                    
                    // If we have a list of videos, pick a random one
                    if let videos = videoResults, !videos.isEmpty {
                        if let randomVideo = videos.randomElement(),
                           let videoLink = randomVideo["link"] as? String {
                            print("Found Random Video Link: \(videoLink)")
                            completion(videoLink)
                            return
                        }
                    }
                    
                    print("Error: No video results found in the JSON response.")
                    completion(nil)
                } else {
                    print("Error: Unable to parse JSON response.")
                    completion(nil)
                }
            } catch let parsingError {
                print("Error: JSON parsing failed with error: \(parsingError.localizedDescription)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    func fetchSpotifyMusic(for mood: String, completion: @escaping (String?) -> Void) {
         let query = "\(mood) mood uplifting music"
         let urlString = "https://serpapi.com/search.json?search_query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&engine=spotify&api_key=\(apiKey)"
         
         print("Spotify Request URL: \(urlString)")
         
         guard let url = URL(string: urlString) else {
             print("Error: Invalid Spotify URL.")
             completion(nil)
             return
         }
         
         // Perform the network request
         let task = URLSession.shared.dataTask(with: url) { data, response, error in
             if let error = error {
                 print("Error: Spotify network request failed with error: \(error.localizedDescription)")
                 completion(nil)
                 return
             }
             
             guard let data = data else {
                 print("Error: No data received from Spotify API.")
                 completion(nil)
                 return
             }
             
             do {
                 if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                     print("Spotify JSON Response: \(json)")
                     if let tracks = json["tracks"] as? [[String: Any]] {
                         print("Extracted Spotify Tracks: \(tracks)")
                         if let randomTrack = tracks.randomElement(),
                            let trackLink = randomTrack["link"] as? String {
                             print("Found Spotify Track Link: \(trackLink)")
                             completion(trackLink)
                             return
                         }
                     }
                     if let spotifyResults = json["spotify_results"] as? [[String: Any]] {
                         print("Extracted Spotify Results: \(spotifyResults)")
                         if let randomResult = spotifyResults.randomElement(),
                            let trackLink = randomResult["link"] as? String {
                             print("Found Spotify Track Link: \(trackLink)")
                             completion(trackLink)
                             return
                         }
                     }
                     print("Error: No Spotify tracks found in the JSON response.")
                     completion(nil)
                 } else {
                     print("Error: Unable to parse Spotify JSON response.")
                     completion(nil)
                 }
             } catch let parsingError {
                 print("Error: Spotify JSON parsing failed with error: \(parsingError.localizedDescription)")
                 completion(nil)
             }
         }
         task.resume()
     }
}
