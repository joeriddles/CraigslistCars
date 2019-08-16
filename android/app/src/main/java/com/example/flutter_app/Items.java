package com.example.flutter_app;

import android.os.AsyncTask;
import android.util.Log;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class Items extends AsyncTask<Void, Void, List<HashMap<String, Object>>> {
    private static final String URL = "https://spokane.craigslist.org/search/";

    private HashMap<String,String> params;

    Items(HashMap<String,String> params) {
        this.params = params;
    }

    @Override
    protected List<HashMap<String, Object>> doInBackground(Void... voids) {
        try {
            Document document;
            if (params != null && !params.isEmpty()) {
                // String[] required to use forEach with a final variable
                final String[] queryUrl = {URL};

                // Are we searching all, owner or dealers?
                queryUrl[0] = params.containsKey("seller")
                        ? queryUrl[0] + params.get("seller")
                        : queryUrl[0] + "cta";
                // Remove `seller` KVP now that we're done with it.
                params.remove("seller");

                // Do we have any parameters?
                if (params.size() > 0)
                    queryUrl[0] = queryUrl[0] + "?";

                // Add any parameters to our request.
                params.forEach((k,v) -> {
                    // Only add parameter if there's a valid, non-empty value.
                    if (!v.isEmpty() && !v.toLowerCase().equals("false") && !v.equals("0"))
                        queryUrl[0] = queryUrl[0] + k + "=" + v + "&";
                });

                Log.d("Craigslist", queryUrl[0]);

                document = Jsoup.connect(queryUrl[0]).get();
            } else {
                document = Jsoup.connect(URL + "cta").get();
            }

            Elements items = document.select(".result-row");

            List<HashMap<String, Object>> maps = new ArrayList<>();
            for (Element item : items) {
                HashMap<String, Object> map = new HashMap<>();

                Element link = item.selectFirst(".result-title");
                map.put("itemUrl", link.attr("abs:href"));
                map.put("title", link.text());

                map.put("price", item.select(".result-price").first().text());

                String imgIds = item.select(".result-image")
                        .first()
                        .attributes()
                        .get("data-ids")
                        .replace("1:", "");
                map.put("img", imgIds);

                maps.add(map);
            }
            return maps;

        } catch (IOException e) {
            // TODO: Better exception handling here...
            e.printStackTrace();
            return null;
        }
    }
}
