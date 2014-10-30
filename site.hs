--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import           Hakyll.Core.Compiler


--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
    tags <- buildTags "posts/*" (fromCapture "tags/*.html")
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "public/*" $ do
        route   idRoute
        compile copyFileCompiler

    match (fromList ["about.markdown", "contact.html", "resume.markdown"]) $ do
        route   $ setExtension "html"
        compile $ do
            tagshtml <- renderTagList tags
            pandocCompiler
                >>= loadAndApplyTemplate "templates/default.html" (defaultCtx tagshtml)
                >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ do
            tagshtml <- renderTagList tags
            pandocCompiler
                >>= loadAndApplyTemplate "templates/post.html"    (postCtx tagshtml)
                >>= loadAndApplyTemplate "templates/default.html" (postCtx tagshtml)
                >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            tagshtml <- renderTagList tags
            let archiveCtx =
                    listField "posts" (postCtx tagshtml) (return posts) `mappend`
                    constField "title" "Archives"                       `mappend`
                    (defaultCtx tagshtml)

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    tagsRules tags $ \tag pattern -> do
        let title = "Posts tagged '" ++ tag ++ "'"
        route idRoute
        compile $ do
            tagshtml <- renderTagList tags
            list <- postList tagshtml tags pattern recentFirst
            tagshtml <- renderTagList tags
            makeItem ""
                >>= loadAndApplyTemplate "templates/tags.html"
                        (constField "title" title `mappend`
                            constField "body" list `mappend`
                            (defaultCtx tagshtml))
                >>= loadAndApplyTemplate "templates/default.html"
                        (constField "title" title `mappend`
                            (defaultCtx tagshtml))
                >>= relativizeUrls


    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            tagshtml <- renderTagList tags
            let indexCtx =
                    listField "posts" (postCtx tagshtml) (return $ take 5 posts) `mappend`
                    constField "title" "Home"                           `mappend`
                    (defaultCtx tagshtml)

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
postCtx :: String -> Context String
postCtx tags =
    dateField "date" "%B %e, %Y" `mappend`
    defaultCtx tags

defaultCtx :: String -> Context String
defaultCtx tags = 
    constField "tags" tags `mappend`
    defaultContext

tagsCtx :: String -> Tags -> Context String
tagsCtx tagshtml tags =
    tagsField "prettytags" tags `mappend`
    postCtx tagshtml

postList :: String -> Tags -> Pattern -> ([Item String] 
         -> Compiler [Item String]) -> Compiler String
postList tagshtml tags pattern preprocess' = do
    postItemTpl <- loadBody "templates/specific-tag-post.html"
    posts <- preprocess' =<< loadAll pattern
    applyTemplateList postItemTpl (tagsCtx tagshtml tags) posts
