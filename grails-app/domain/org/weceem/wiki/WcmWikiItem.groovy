package org.weceem.wiki

import org.weceem.content.*

/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 *
 * @author Stephan Albers
 * @author July Karpey
 */
class WcmWikiItem extends WcmContent {

    static searchable = {
        alias WcmWikiItem.name.replaceAll("\\.", '_')
        only = ['content', 'keywords', 'title', 'status']
    }
    
    static icon = [plugin: "weceem", dir: "_weceem/images/weceem/content-icons", file: "wiki-32.png"]

    String keywords
    WcmTemplate template

    // 64Kb Unicode text with HTML/Wiki Markup
    String content

    @Override
    String getHardDependencies() {
        // A template is an implicit dependency for the node, any changes to the template or its deps
        // means we have to change too.
        def t = TemplateUtils.getTemplateForContent(this)
        return t ? t.absoluteURI : ''
    }

    /**
     * Must be overriden by content types that can represent their content as text.
     * Used for search results and versioning
     */
    public String getContentAsText() { content }

    
    Map getVersioningProperties() { 
        super.getVersioningProperties() + [ 
            keywords:keywords,
            template:template?.ident() // Is this right?
        ] 
    }
    
    static constraints = {
        content(nullable: false, maxSize: WcmContent.MAX_CONTENT_SIZE)
        keywords(nullable: true)
        template(nullable: true)
        status(nullable: false) // Workaround for Grails 1.1.1 constraint inheritance bug
    }

    static mapping = {
        template cascade: 'all', lazy: false // we never want proxies for this
        cache usage: 'read-write'
        columns {
            content type:'text'
        }
    }
    
    static editors = {
        template(group:'extra')
        content(editor:'WikiCode')
        keywords(group:'meta')
    }

    static transients = WcmContent.transients + ['summary']

    public String getSummary() {
        def summaryString = ""
        def parts = content.split("<")
        parts.each() {
            def modified = it.substring(it.indexOf(">") + 1)
            if (modified) summaryString += modified
        }

        if (content && summaryString.length() >= 100) {
            summaryString = summaryString.substring(0, 99)
            summaryString = summaryString.substring(0, summaryString.lastIndexOf(" "))
        }

        return summaryString
    }

    public void setSummary(String summary) {}  
}
