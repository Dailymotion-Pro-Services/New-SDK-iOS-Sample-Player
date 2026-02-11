import Foundation

struct Video {
    let id: String
    let title: String
    let thumbnailURL: URL

    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let title = dictionary["title"] as? String,
              let thumbnailURLString = dictionary["thumbnail_240_url"] as? String,
              let thumbnailURL = URL(string: thumbnailURLString) else {
            return nil
        }

        self.id = id
        self.title = title
        self.thumbnailURL = thumbnailURL
    }
}

enum VideoService {
    static func fetchVideos(completion: @escaping ([Video]) -> Void) {
        let dailymotionURL = "https://api.dailymotion.com/videos?fields=id,thumbnail_240_url,title&limit=5&owners=suaradotcom"

        guard let url = URL(string: dailymotionURL) else {
            print("🔥 dm: Invalid URL")
            completion([])
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let videos = json["list"] as? [[String: Any]] {
                        let converted = videos.compactMap { Video(dictionary: $0) }
                        completion(converted)
                    } else {
                        print("🔥 dm: Failed to parse JSON")
                        completion([])
                    }
                } catch {
                    print("🔥 dm: \(error.localizedDescription)")
                    completion([])
                }
            } else {
                print("🔥 dm: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
            }
        }

        task.resume()
    }
}
