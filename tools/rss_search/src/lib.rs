use serde::Serialize;

wasm_component::component!(path = "../wit");

#[derive(Serialize)]
struct FeedEntry {
    title: String,
    link: String,
    published: String,
    summary_ai: String,
}

struct RssSearch;

impl rss::search::search::Guest for RssSearch {
    fn rss_latest(limit: u32) -> String {
        let entries: Vec<FeedEntry> = (0..limit)
            .map(|i| FeedEntry {
                title: format!("Demo Article {}", i),
                link: format!("https://example.com/article{}", i),
                published: "2025-09-27T12:00:00Z".to_string(),
                summary_ai: format!("This is a test summary for item {}", i),
            })
            .collect();

        serde_json::to_string(&entries).unwrap()
    }

    fn rss_search(query: String, limit: u32) -> String {
        let results: Vec<FeedEntry> = (0..limit)
            .map(|i| FeedEntry {
                title: format!("Result {} for {}", i, query),
                link: format!("https://example.com/search/{}/{}", query, i),
                published: "2025-09-27T12:00:00Z".to_string(),
                summary_ai: format!("This is a search result for {}", query),
            })
            .collect();

        serde_json::to_string(&results).unwrap()
    }
}

export!(RssSearch);
