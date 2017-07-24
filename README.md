# Ocarina

[![Build Status](https://travis-ci.org/awkward/Ocarina.svg?branch=master)](https://travis-ci.org/awkward/Ocarina)
[![Contact](https://img.shields.io/badge/contact-madeawkward-blue.svg?style=flat)](https://twitter.com/madeawkward)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A library to receive metadata and Open Graph information from URLs.

### Introduction

Hi, we're [Awkward](https://awkward.co/). We were looking for a way to visualize information behind links to present these in our iOS reddit client called [Beam](https://beamreddit.com/). We initially used a server to receive metadata, but the server became quite crowded with calls. We built Ocarina as a solution to that problem. Fallbacks for basic HTML tags and Twitter card information make this metadata fetcher unique. We welcome you to use Ocarina for your own projects.

### Features

- Fetching of basic metadata for individual links using the OGP protocol or basic HTML tags (twitter card information also available)
- Memory cache of metadata for each link
- Prefetching a set of links to make views more responsive
- Link information can include: type, title, description, image, image size, favicon, and Apple touch icon

### Installation


1. Drag Ocarina.xcodeproj into your project
2. Go to your project
3. Select Build Phases
4. Under Embed frameworks, press + and select Ocarina.framework
5. Select Build Settings
6. Search for `Other Linker Flags` and add `-lxml2`

### Usage

### Fetching information for a single link

```Swift
let url = URL(string: "https://awkward.co")!
link.oca.fetchInformation(completionHandler: { (information, error) in
  if let information = information {
    print(String(describing: information.title))
  } else if let error = error {
    print(String(describing: error))
  }

})
```

### Prefetching multiple links

OcarinaPrefetcher allows prefetching links into the cache, this allows for the UI to look more responsive.

```Swift
let urls = [
  URL(string: "https://awkward.co")!,
  URL(string: "https://facebook.com")!,
  URL(string: "https://nytimes.com")!,
  URL(string: "https://latimes.com")!
]
let prefetcher = OcarinaPrefetcher(urls: urls, completionHandler: { (errors) in§
  print("Done pre-fetching links")
})
```

For other uses, see the example project

### Contributing

Contributing is easy. If you want to report an error of any kind, please create an issue. If you want to propose a change, a pull request is the right way to go.

### License


> Ocarina is available under the MIT license. See the LICENSE file for more info.

### Links

  - [Awkward](https://awkward.co)
  - [Beam](https://beamreddit.com)
