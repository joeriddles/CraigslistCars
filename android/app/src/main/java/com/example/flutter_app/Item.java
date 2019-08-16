package com.example.flutter_app;

import android.os.AsyncTask;
import android.util.Log;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.ocpsoft.prettytime.*;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;

public class Item extends AsyncTask<Void, Void, HashMap<String, String>> {
    private String itemUrl;

    Item(String itemUrl) {
        this.itemUrl = itemUrl;
    }

    @Override
    protected HashMap<String, String> doInBackground(Void... voids) {
        try {
            Log.d("Craigslist", itemUrl);

            Document document = Jsoup.connect(itemUrl).get();

            Elements items = document.select(".attrgroup");
            // Should return 2 (or more?)

            HashMap<String,String> attributes = new HashMap<>();

            if (items.size() > 0) {
                attributes.put("title", items.get(0).text());
            }
            if (items.size() > 1) {
                Elements spans = items.get(1).select("span");
                for (Element span : spans) {
                    // HTML looks like "... key : value ..." in span
                    String[] strings = span.text().split(":");
                    if (strings.length == 2) {
                        attributes.put(strings[0], span.text());
                    }
                }
            }

            Elements postingBody = document.select("#postingbody");
            if (postingBody.size() > 0) {
                if (postingBody.first().child(0).hasClass("print-qrcode-container")) {
                    postingBody.first().child(0).text("");
                }

                attributes.put("postingbody", postingBody.get(0).html());
            }

            String datePosted = document.select(".date").first().text();
            try {
                Date date = new SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.ENGLISH).parse(datePosted);
                PrettyTime now = new PrettyTime(new Date());
                attributes.put("date", now.format(date));
            } catch (ParseException e) {
                // Don't add date if we cant parse it. ¯\_(ツ)_/¯
            }


            return attributes;
        } catch (IOException e) {
            // TODO: Better exception handling here...
            e.printStackTrace();
            return null;
        }
    }
}
