package com.example.flutter_app;

import android.os.Bundle;

import java.util.HashMap;
import java.util.List;
import java.util.concurrent.ExecutionException;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.flutter.dev/craigslist";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    switch (call.method) {
                        case "getItems": {
                            HashMap<String, String> params = new HashMap<>();
                            if (call.hasArgument("params")) {
                                params = call.argument("params");
                            }

                            List<HashMap<String, Object>> items = getItems(params);

                            if (items != null && !items.isEmpty()) {
                                result.success(items);
                            } else {
                                result.error("ERROR", "itemTitles is null or empty.", null);
                            }
                            break;
                        }
                        case "getItem": {
                            String itemUrl = call.argument("itemUrl");
                            HashMap<String, String> item = getItem(itemUrl);
                            if (item != null) {
                                result.success(item);
                            } else {
                                result.error("ERROR", "item is null", null);
                            }
                            break;
                        }
                        default:
                            result.notImplemented();
                    }
                }
        );
    }

    public List<HashMap<String, Object>> getItems(HashMap<String, String> params) {
        try {
            return new Items(params).execute().get();
        } catch (ExecutionException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        return null;
    }

    public HashMap<String, String> getItem(String itemUrl) {
        try {
            return new Item(itemUrl).execute().get();
        } catch (ExecutionException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        return null;
    }
}
