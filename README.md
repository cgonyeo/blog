My blog. Uses Hakyll. To build:

```
cabal install hakyll
ghc --make -threaded site.hs
./site build
```

and then the site will be in `./_site/`
