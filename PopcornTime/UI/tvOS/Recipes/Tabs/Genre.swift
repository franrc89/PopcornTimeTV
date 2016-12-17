

import TVMLKitchen
import PopcornKit

struct Genre: TabItem {
    
    let title = "Genre"
    let fetchType: Trakt.MediaType
    
    init(_ type: Trakt.MediaType) {
        fetchType = type
    }

    func handler() {
        serveRecipe(GenreRecipe(fetchType: fetchType))
    }


    func serveRecipe(_ recipe: GenreRecipe) {
        Kitchen.appController.evaluate(inJavaScriptContext: { context in
            let highlightSection: @convention(block) (String, JSValue) -> () = { (text, callback) in
                recipe.section(didHighlightWithGenre: text) { string in
                    if callback.isObject {
                        callback.call(withArguments: [string])
                    }
                }
            }

            context.setObject(unsafeBitCast(highlightSection, to: AnyObject.self), forKeyedSubscript: "highlightSection" as (NSCopying & NSObjectProtocol)!)

            if let file = Bundle.main.url(forResource: "Genre", withExtension: "js") {
                do {
                    var js = try String(contentsOf: file)
                    js = js.replacingOccurrences(of: "{{RECIPE}}", with: recipe.xmlString)
                    context.evaluateScript(js)
                } catch {
                    print("Could not open Genre.js")
                }
            }
        }, completion: nil)
    }
}
