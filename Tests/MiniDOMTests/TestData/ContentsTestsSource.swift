//
//  ContentsTestsSource.swift
//  MiniDOM
//
//  Copyright 2017-2019 Anodized Software, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import Foundation

let contentsTestsSource = [
"<?xml version=\"1.0\"?>",
"",
"<?xml-stylesheet href=\"XSL\\JavaXML.html.xsl\" type=\"text/xsl\"?>",
"<?xml-stylesheet href=\"XSL\\JavaXML.wml.xsl\" type=\"text/xsl\" ",
"                 media=\"wap\"?>",
"<?cocoon-process type=\"xslt\"?>",
"",
"<!-- Java and XML -->",
"<JavaXML:Book xmlns:JavaXML=\"http://www.oreilly.com/catalog/javaxml/\" ",
"              xmlns:ora=\"http://www.oreilly.com\"",
"              xmlns:unused=\"http://www.unused.com\"",
"              ora:category=\"Java\" ",
"> ",
"  <!-- comment one -->",
"  <!-- comment two -->",
"",
" <JavaXML:Title>Java and XML</JavaXML:Title>",
" <JavaXML:Contents xmlns:topic=\"http://www.oreilly.com/topics\">",
"  <JavaXML:Chapter topic:focus=\"XML\">",
"   <JavaXML:Heading>Introduction</JavaXML:Heading>",
"   <JavaXML:Topic subSections=\"7\">",
"     What Is It?",
"   </JavaXML:Topic>",
"   <JavaXML:Topic subSections=\"3\">",
"     How Do I Use It?",
"   </JavaXML:Topic>",
"   <JavaXML:Topic subSections=\"4\">",
"     Why Should I Use It?",
"   </JavaXML:Topic>",
"   <JavaXML:Topic subSections=\"0\">",
"     What's Next?",
"   </JavaXML:Topic>",
"  </JavaXML:Chapter>",
"",
"  <JavaXML:Chapter topic:focus=\"XML\">",
"   <JavaXML:Heading>Creating XML</JavaXML:Heading>",
"   <JavaXML:Topic subSections=\"0\">An XML Document</JavaXML:Topic>",
"   <JavaXML:Topic subSections=\"2\">The Header</JavaXML:Topic>",
"   <JavaXML:Topic subSections=\"6\">The Content</JavaXML:Topic>",
"   <JavaXML:Topic subSections=\"1\">What's Next?</JavaXML:Topic>",
"  </JavaXML:Chapter>",
"",
"  <JavaXML:Chapter topic:focus=\"Java\">",
"   <JavaXML:Heading>Parsing XML</JavaXML:Heading>",
"   <JavaXML:Topic subSections=\"3\">Getting Prepared</JavaXML:Topic>",
"   <JavaXML:Topic subSections=\"3\">SAX Readers</JavaXML:Topic>",
"   <JavaXML:Topic subSections=\"9\">Content Handlers</JavaXML:Topic>",
"   <JavaXML:Topic subSections=\"4\">Error Handlers</JavaXML:Topic>",
"   <JavaXML:Topic subSections=\"0\">",
"     A Better Way to Load a Parser",
"   </JavaXML:Topic>",
"   <JavaXML:Topic subSections=\"4\">\"Gotcha!\"</JavaXML:Topic>",
"   <JavaXML:Topic subSections=\"0\">What's Next?</JavaXML:Topic>",
"  </JavaXML:Chapter>",
"",
"  <JavaXML:SectionBreak/>",
"",
"  <JavaXML:Chapter topic:focus=\"Java\">",
"   <JavaXML:Heading>Web Publishing Frameworks</JavaXML:Heading>",
"   <JavaXML:Topic subSections=\"4\">Selecting a Framework</JavaXML:Topic>",
"   <JavaXML:Topic subSections=\"4\">Installation</JavaXML:Topic>",
"   <JavaXML:Topic subSections=\"3\">",
"     Using a Publishing Framework",
"   </JavaXML:Topic>",
"   <JavaXML:Topic subSections=\"2\">XSP</JavaXML:Topic>",
"   <JavaXML:Topic subSections=\"3\">Cocoon 2.0 and Beyond</JavaXML:Topic>",
"   <JavaXML:Topic subSections=\"0\">What's Next?</JavaXML:Topic>",
"  </JavaXML:Chapter>",
" </JavaXML:Contents>",
"</JavaXML:Book>",
].joined(separator: "\n")
