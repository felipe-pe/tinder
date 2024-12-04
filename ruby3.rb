POST https://api.gotinder.com/user/recs HTTP/1.1
app_version: 633
platform: android
User-Agent: Tinder Android Version 2.2.3
X-Auth-Token: b5b820ac-aede-4fe2-b6a3-92cc921c6a5c
os_version: 19
Content-Type: application/json; charset=utf-8
Host: api.gotinder.com
Connection: Keep-Alive
Accept-Encoding: gzip
Content-Length: 12
 
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Content-Length: 63452
Connection: keep-alive
 
{
  "status": 200,
  "results": [
    {
      "distance_mi": 15,
      "common_like_count": 0,
      "common_friend_count": 0,
      "common_likes": [],
      "common_friends": [],
      "_id": "5366c93490d3e94c03006b25",
      "bio": "",
      "birth_date": "1991-10-13T00:00:00.000Z",
      "gender": 1,
      "name": "Sample Profile",
      "ping_time": "2014-08-04T23:11:48.133Z",
      "photos": [
        {
          "url": "http://images.gotinder.com/0001unknown/unknown.jpg",
          "processedFiles": [
            {
              "url": "http://images.gotinder.com/0001unknown/640x640_pct_0_0_100_100_unknown.jpg",
              "height": 640,
              "width": 640
            },
            {
              "url": "http://images.gotinder.com/0001unknown/320x320_pct_0_0_100_100_unknown.jpg",
              "height": 320,
              "width": 320
            },
            {
              "url": "http://images.gotinder.com/0001unknown/172x172_pct_0_0_100_100_unknown.jpg",
              "height": 172,
              "width": 172
            },
            {
              "url": "http://images.gotinder.com/0001unknown/84x84_pct_0_0_100_100_unknown.jpg",
              "height": 84,
              "width": 84
            }
          ],
          "extension": "jpg",
          "fileName": "unknown.jpg",
          "crop": "source",
          "main": true,
          "id": "unknown"
        }
      ],
      "birth_date_info": "fuzzy birthdate active, not displaying real birth_date"
    }
  ]
}
GET https://api.gotinder.com/like/5351dca99307257152001ced HTTP/1.1
app_version: 633
platform: android
User-Agent: Tinder Android Version 2.2.3
X-Auth-Token: b5b820ac-aede-4fe2-b6a3-92cc921c6a5c
os_version: 19
Host: api.gotinder.com
Connection: Keep-Alive
Accept-Encoding: gzip
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
X-Auth-Token: b5b820ac-aede-4fe2-b6a3-92cc921c6a5c
Content-Length: 15
Connection: keep-alive
 
{"match":false}
public static List<string> GetProspects()
{
    List<string> ids = new List<string>();
    string response;
 
    try
    {
        using (WebClient wc = new WebClient())
        {
            wc.Headers[HttpRequestHeader.ContentType] = "application/json; charset=utf-8";
            wc.Headers[HttpRequestHeader.UserAgent] = "Tinder Android Version 3.2.0";
            wc.Headers.Add("X-Auth-Token", "357d0c7f-6836-4e4b-9cfe-8f990af1ecfe");
            wc.Headers.Add("os-version", "19");
            wc.Headers.Add("app-version", "757");
            response = wc.UploadString("https://api.gotinder.com/user/recs", "{"limit":40}");
        }
    }
    catch
    {
        return ids;
    }
 
    if (!string.IsNullOrWhiteSpace(response))
    {
        dynamic dataObj = JObject.Parse(response);
        if (dataObj.status == "200")
        {
            foreach (dynamic result in dataObj.results)
            {
                string str = result._id;
 
                ids.Add(str);
            }
        }
    }
 
    return ids;
}public static void LikeUser(string userId)
{
 
    string uri = "https://api.gotinder.com/like/" + userId;
    using (WebClient wc = new WebClient())
    {
        wc.Headers[HttpRequestHeader.UserAgent] = "Tinder Android Version 3.2.0";
        wc.Headers.Add("X-Auth-Token", "b5b820ac-aede-4fe2-b6a3-92cc921c6a5c");
        wc.Headers.Add("os-version", "19");
        wc.Headers.Add("app-version", "757");
        wc.Headers.Add("aplatform", "android");
        try
        {
            wc.DownloadString(uri);
        }
        catch { } // Kids, don't try this in production code!
 
    }
}
        end

        