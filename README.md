# Electron Starter App

electron-starter is a base application that you can use to get started writing your own cross-platform (Win/Mac/Linux) Desktop apps via Electron. This template is extracted from the Atom source code, cleaned up to be more generic, and to be a great starting point for a production app.

### Getting Started

Everything in Electron Starter is configured via the `package.json` file - there are some extra fields that are of interest:

* `name` - The name for your app that will be used in the build tools. Make it something simple.
* `productName` - The name of your product - your executable will be called this (i.e. "MyApp.app")

The default project is called EightOhEight (get it? Cause it's a sample(r)).

Once you've set that up, do:

1. `script/bootstrap` - Run this once per checkout.
2. `script/build` - Run this whenever you change package.json or change early startup code
3. `script/run` - Run the app. Use this for running the app in developer mode

Another useful script is `script/grunt`, which will run the local version of Grunt. `script/grunt --help` will tell you the list of available tasks.

### Using JavaScript ES6

JavaScript ES6 / ESNext is available via the Babel project for almost all files except for very early in startup. To use it, add `'use babel';` to the top of your file. Check out https://babeljs.io for more information. 

### What's the "browser" vs "renderer" code?

Electron has (at least) two separate contexts - when your app first starts up, it is running in a DOM-less node.js loop - there are no windows. This is called the *Browser* context. The built-in code proceeds to start up a `BrowserWindow` object, which then creates a *Rendering* context, which is what you are more used to - it's got the Chrome DevTools and a DOM, yet it can *still* use node.js, as well as several Electron APIs that are made available. Check out the [documentation for Electron](https://github.com/atom/atom-shell/tree/master/docs/api) for more about what you can do.

Most of your app's code should ideally live in the *Rendering* context, because the Browser context is difficult to debug and test - there is no Chrome DevTools, solely printf-based debugging.

### Why does `$MY_FAVORITE_LIBRARY` not work / do weird stuff?

Some JavaScript libraries try to detect whether they're in node.js via probing for `module` or `require`, and assume that they aren't in a browser. You might find that you need to patch these libraries to always operate in Browser Mode.
