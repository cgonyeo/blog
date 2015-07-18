My blog. Uses Hakyll. To build:

```
cabal sandbox init
cabal install --only-dependencies
cabal build
./dist/build/blog/blog build
```

and then the site will be in `./_site/`
