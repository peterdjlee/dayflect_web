'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "index.html": "947932a8dff865cd1f2adcef9138583a",
"/": "947932a8dff865cd1f2adcef9138583a",
"main.dart.js": "cca2153e5b06647f0c8e40d81f22811e",
"icons/favicon-16x16.png": "6c682790732e7cb2184fbf62d303fa6c",
"icons/mstile-310x310.png": "ec334d82dddd29208aecae396c74e17f",
"icons/mstile-144x144.png": "523d2cb58af6315a207512a6b47da950",
"icons/favicon.ico": "4c2de9c6ffc516998a14e03b60a8357e",
"icons/apple-touch-icon-120x120.png": "d43beadd70d5dfe8ad81dea192f949a0",
"icons/favicon-196x196.png": "3c221e14f27ea07a40797a805792109a",
"icons/mstile-70x70.png": "f4f536f3484d8051bcab799c3ed8979a",
"icons/apple-touch-icon-152x152.png": "bb726c95e4aa2df1a9d4d4aad20a889c",
"icons/code.txt": "3eefd6f286ef79e3471e70d6bd75469a",
"icons/mstile-310x150.png": "98ec48c31df2622441e5f0a37316805b",
"icons/apple-touch-icon-114x114.png": "60d464d4c7fafd90a38031a42d2d2463",
"icons/apple-touch-icon-76x76.png": "350933b0a8a4cf5fa873d4c6412e1d9c",
"icons/favicon-128.png": "f4f536f3484d8051bcab799c3ed8979a",
"icons/favicon-96x96.png": "d115803c2bdb9ecd9c18e46f3eb0a571",
"icons/apple-touch-icon-57x57.png": "b0598db049e61fcc0561055111b676cf",
"icons/apple-touch-icon-72x72.png": "f918e701eb8bb4c592559860bfe517a0",
"icons/mstile-150x150.png": "2da603b105e528b9530e2458e3428e64",
"icons/apple-touch-icon-60x60.png": "a1b37d98e18013f95a84ca07d866f488",
"icons/apple-touch-icon-144x144.png": "523d2cb58af6315a207512a6b47da950",
"icons/favicon-32x32.png": "756533fd2d1d78a0740f7d6e35450a9c",
"assets/white_logo.png": "c331066a2e2772c39f437c902faa1c06",
"assets/download_play_store.png": "48ba414c75d4fcc3cca449f53ddacd09",
"assets/download_app_store.png": "80c7a7af0edfb6b7f9f5606f812e195f",
"assets/AssetManifest.json": "0c0656dfb28a0e9c62675df5a89d9a75",
"assets/NOTICES": "bcfd0e360fef47d3db90b26a06ccae13",
"assets/galaxy_read_screenshot.png": "3cbb6183fadae32d9abbdc7e9fedd25b",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/fonts/MaterialIcons-Regular.otf": "a68d2a28c526b3b070aefca4bac93d25",
"assets/assets/white_logo.png": "c331066a2e2772c39f437c902faa1c06",
"assets/assets/download_play_store.png": "48ba414c75d4fcc3cca449f53ddacd09",
"assets/assets/download_app_store.png": "80c7a7af0edfb6b7f9f5606f812e195f",
"assets/assets/galaxy_read_screenshot.png": "3cbb6183fadae32d9abbdc7e9fedd25b"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      // Provide a 'reload' param to ensure the latest version is downloaded.
      return cache.addAll(CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');

      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }

      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#')) {
    key = '/';
  }
  // If the URL is not the RESOURCE list, skip the cache.
  if (!RESOURCES[key]) {
    return event.respondWith(fetch(event.request));
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache. Ensure the resources are not cached
        // by the browser for longer than the service worker expects.
        var modifiedRequest = new Request(event.request, {'cache': 'reload'});
        return response || fetch(modifiedRequest).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    return self.skipWaiting();
  }

  if (event.message === 'downloadOffline') {
    downloadOffline();
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey in Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
