---
layout: post
title:  "Lexers supported by Rouge v1.3.1"
date:   2016-03-10 20:05:10
comments: Yes
tags:
  - rouge
  - test page
categories:
  - test page
assets:
---

This page has been shamelessly lifted from [Rouge’s demo site](http://rouge.jayferd.us/demo).  I am using it to verify synstax highlighting on my site.  Please refer to the original Rouge documentation for an authoritative list of lexers supported by rouge.

#### c

*The C programming language*

``` c
#include "ruby/ruby.h"

static int
clone_method_i(st_data_t key, st_data_t value, st_data_t data)
{
    clone_method((VALUE)data, (ID)key, (const rb_method_entry_t *)value);
    return ST_CONTINUE;
}
```

#### clojure

aliased as clj, cljs

*The Clojure programming language (clojure.org)*

``` clojure
(defn make-adder [x]
  (let [y x]
    (fn [z] (+ y z))))
(def add2 (make-adder 2))
(add2 4)
```

#### coffeescript

aliased as coffee, coffee-script

*The Coffeescript programming language (coffeescript.org)*

``` coffeescript
# Objects:
math =
  root:   Math.sqrt
  square: square
  cube:   (x) -> x * square x
```

#### common_lisp

aliased as cl, common-lisp

*The Common Lisp variant of Lisp (common-lisp.net)*

``` cl
(defun square (x) (* x x))
```

#### conf

aliased as config, configuration

*A generic lexer for configuration files*

``` conf
# A generic configuration file
option1 "val1"
option2 23
option3 'val3'
```

#### cpp

aliased as c++

*The C++ programming language*

``` cpp
#include<iostream>

using namespace std;

int main()
{
    cout << "Hello World" << endl;
}
```

#### csharp

aliased as c#, cs

*a multi-paradigm language targeting .NET*

``` csharp
// reverse byte order (16-bit)
public static UInt16 ReverseBytes(UInt16 value)
{
  return (UInt16)((value & 0xFFU) << 8 | (value & 0xFF00U) >> 8);
}
```

#### css

*Cascading Style Sheets, used to style web pages*

``` css
body {
    font-size: 12pt;
    background: #fff url(temp.png) top left no-repeat;
}
```

#### diff

aliased as patch, udiff

*Lexes unified diffs or patches*

``` diff
--- file1   2012-10-16 15:07:58.086886874 +0100
+++ file2   2012-10-16 15:08:07.642887236 +0100
@@ -1,3 +1,3 @@
 a b c
-d e f
+D E F
 g h i
```

#### elixir

*Elixir language (elixir-lang.org)*

``` elixir
Enum.map([1,2,3], fn(x) -> x * 2 end)
```

#### erb

aliased as eruby, rhtml

*Embedded ruby template files*

``` erb
<title><%= @title %></title>
```

#### erlang

aliased as erl

*The Erlang programming language (erlang.org)*

``` erlang
%%% Geometry module.
-module(geometry).
-export([area/1]).

%% Compute rectangle and circle area.
area({rectangle, Width, Ht}) -> Width * Ht;
area({circle, R})            -> 3.14159 * R * R.
```

#### factor

*Factor, the practical stack language (factorcode.org)*

``` factor
USING: io kernel sequences ;

4 iota [
    "Happy Birthday " write 2 = "dear NAME" "to You" ? print
] each
```

#### gherkin

aliased as cucumber, behat

*A business-readable spec DSL ( github.com/cucumber/cucumber/wiki/Gherkin )*

``` gherkin
# language: en
Feature: Addition
  In order to avoid silly mistakes
  As a math idiot
  I want to be told the sum of two numbers

  Scenario Outline: Add two numbers
    Given I have entered <input_1> into the calculator
    And I have entered <input_2> into the calculator
    When I press <button>
    Then the result should be <output> on the screen

  Examples:
    | input_1 | input_2 | button | output |
    | 20      | 30      | add    | 50     |
    | 2       | 5       | add    | 7      |
    | 0       | 40      | add    | 40     |
```

#### go

aliased as go, golang

*The Go programming language (http://golang.org)*

``` go
package main

import "fmt"

func main() {
    fmt.Println("Hello, 世界")
}
```

#### groovy

*The Groovy programming language (groovy.codehaus.org)*

``` groovy
class Greet {
  def name
  Greet(who) { name = who[0].toUpperCase() +
                      who[1..-1] }
  def salute() { println "Hello $name!" }
}

g = new Greet('world')  // create object
g.salute()               // output "Hello World!"
```

#### haml

aliased as HAML

*The Haml templating system for Ruby (haml.info)*

``` haml
%section.container
  %h1= post.title
  %h2= post.subtitle
  .content
    = post.content
```

#### handlebars

aliased as hbs, mustache

*the Handlebars and Mustache templating languages*

``` hbs
<div class="entry">
  <h1>{{title}}</h1>
  {{#with story}}
    <div class="intro">{{{intro}}}</div>
    <div class="body">{{{body}}}</div>
  {{/with}}
</div>
```

#### haskell

aliased as hs

*The Haskell programming language (haskell.org)*

``` hs
quicksort :: Ord a => [a] -> [a]
quicksort []     = []
quicksort (p:xs) = (quicksort lesser) ++ [p] ++ (quicksort greater)
    where
        lesser  = filter (< p) xs
        greater = filter (>= p) xs
```

#### html

*HTML, the markup language of the web*

``` html
<html>
  <head><title>Title!</title></head>
  <body>
    <p id="foo">Hello, World!</p>
    <script type="text/javascript">var a = 1;</script>
    <style type="text/css">#foo { font-weight: bold; }</style>
  </body>
</html>
```

#### http

*http requests and responses*

``` http
POST /demo/submit/ HTTP/1.1
Host: rouge.jayferd.us
Cache-Control: max-age=0
Origin: http://rouge.jayferd.us
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_2)
    AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.63 Safari/535.7
Content-Type: application/json
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Referer: http://pygments.org/
Accept-Encoding: gzip,deflate,sdch
Accept-Language: en-US,en;q=0.8
Accept-Charset: windows-949,utf-8;q=0.7,*;q=0.3

{"name":"test","lang":"text","boring":true}
```

#### ini

*the INI configuration format*

``` ini
; last modified 1 April 2001 by John Doe
[owner]
name=John Doe
organization=Acme Widgets Inc.
```

#### io

*The IO programming language (http://iolanguage.com)*

``` io
bottle := method(i,
  if(i==0, return "no more bottles of beer")
  if(i==1, return "1 bottle of beer")
  return i asString .. " bottles of beer"
)

for(i, 99, 1, -1,
  write(bottle(i), " on the wall, ", bottle(i), ",\n")
  write("take one down, pass it around,\n")
  write(bottle(i - 1), " on the wall.\n\n")
)
```

#### java

*The Java programming language (java.com)*

``` java
public class java {
    public static void main(String[] args) {
        System.out.println("Hello World");
    }
}
```

#### javascript

aliased as js

*JavaScript, the browser scripting language*

``` js
$(document).ready(function() { alert('ready!'); });
```

#### json

*JavaScript Object Notation (json.org)*

``` json
{ "one": 1, "two": 2 }
```

#### literate_coffeescript

aliased as litcoffee

*Literate coffeescript*

``` litcoffee
Import the helpers we plan to use.
    {extend, last} = require './helpers'
```

#### literate_haskell

aliased as lithaskell, lhaskell, lhs

*Literate haskell*

``` jhs
In Bird-style you have to leave a blank before the code.

> fact :: Integer -> Integer
> fact 0 = 1
> fact n = n * fact (n-1)

And you have to leave a blank line after the code as well.
```

#### llvm

*The LLVM Compiler Infrastructure (http://llvm.org/)*

``` llvm
; copied from http://llvm.org/docs/LangRef.html#module-structure
; Declare the string constant as a global constant.
@.str = private unnamed_addr constant [13 x i8] c"hello world\0A\00"

; External declaration of the puts function
declare i32 @puts(i8* nocapture) nounwind

; Definition of main function
define i32 @main() {   ; i32()*
  ; Convert [13 x i8]* to i8  *...
  %cast210 = getelementptr [13 x i8]* @.str, i64 0, i64 0

  ; Call puts function to write out the string to stdout.
  call i32 @puts(i8* %cast210)
  ret i32 0
}

; Named metadata
!1 = metadata !{i32 42}
!foo = !{!1, null}
```

#### lua

*Lua (http://www.lua.org)*

``` lua
-- defines a factorial function
function fact (n)
  if n == 0 then
    return 1
  else
    return n * fact(n-1)
  end
end
    
print("enter a number:")
a = io.read("*number")        -- read a number
print(fact(a))
```

#### make

aliased as makefile, mf, gnumake, bsdmake

*Makefile syntax*

``` make
.PHONY: all
all: $(OBJ)

$(OBJ): $(SOURCE)
    @echo "compiling..."
    $(GCC) $(CFLAGS) $< > $@
```

#### markdown

aliased as md, mkd

*Markdown, a light-weight markup language for authors*

``` md
Markdown has cool [reference links][ref 1]
and [regular links too](http://example.com)

[ref 1]: http://example.com
```

#### matlab

aliased as m

*Matlab*

``` m
A = cat( 3, [1 2 3; 9 8 7; 4 6 5], [0 3 2; 8 8 4; 5 3 5], ...
                 [6 4 7; 6 8 5; 5 4 3]);
% The EIG function is applied to each of the horizontal 'slices' of A.
for i = 1:3
    eig(squeeze(A(i,:,:)))
end
```

#### moonscript

aliased as moon

*Moonscript (http://www.moonscript.org)*

``` moon
util = require "my.module"

a_table = {
  foo: 'bar'
  interpolated: "foo-#{other.stuff 2 + 3}"
  "string": 2
  do: 'keyword'
}

class MyClass extends SomeClass
  new: (@init, arg2 = 'default') =>
    @derived = @init + 2
    super!

  other: =>
    @foo + 2
```

#### nginx

*configuration files for the nginx web server (nginx.org)**

``` nginx
server {
  listen          80;
  server_name     example.com *.example.com;
  rewrite ^       http://www.domain.com$request_uri? permanent;
}
```

#### objective_c

aliased as objc

*an extension of C commonly used to write Apple software*

``` objc
@interface Person : NSObject {
  @public
  NSString *name;
  @private
  int age;
}

@property(copy) NSString *name;
@property(readonly) int age;

-(id)initWithAge:(int)age;
@end
```

#### ocaml

*Objective CAML (ocaml.org)*

``` ocaml
(* Binary tree with leaves car­rying an integer. *)
type tree = Leaf of int | Node of tree * tree

let rec exists_leaf test tree =
  match tree with
  | Leaf v -> test v
  | Node (left, right) ->
      exists_leaf test left
      || exists_leaf test right

let has_even_leaf tree =
  exists_leaf (fun n -> n mod 2 = 0) tree
```

#### perl

aliased as pl

*The Perl scripting language (perl.org)*

``` perl
#!/usr/bin/env perl
use warnings;
print "a: ";
my $a = "foo";
print $a;
```

#### php

aliased as php, php3, php4, php5

*The PHP scripting language (php.net)*

``` php
<?php
  print("Hello {$world}");
?>
```

#### plaintext

aliased as text

*A boring lexer that doesn't highlight anything*

``` text
plain text :)
```

#### prolog

aliased as prolog

*The Prolog programming language (http://en.wikipedia.org/wiki/Prolog)*

``` prolog
diff(plus(A,B), X, plus(DA, DB))
   <= diff(A, X, DA) and diff(B, X, DB).

diff(times(A,B), X, plus(times(A, DB), times(DA, B)))
   <= diff(A, X, DA) and diff(B, X, DB).

equal(X, X).
diff(X, X, 1).
diff(Y, X, 0) <= not equal(Y, X).
```

#### puppet

aliased as pp

*The Puppet configuration management language (puppetlabs.org)*

``` puppet
service { 'ntp':
  name      => $service_name,
  ensure    => running,
  enable    => true,
  subscribe => File['ntp.conf'],
}
```

#### python

aliased as py

*The Python programming language (python.org)*

``` pythin
def fib(n):    # write Fibonacci series up to n
    """Print a Fibonacci series up to n."""
    a, b = 0, 1
    while a < n:
        print a,
        a, b = b, a+b
```

#### r

aliased as r, R, s, S

*The R statistics language (r-project.org)*

``` r
dbenford <- function(x){
    log10(1 + 1/x)
}

pbenford <- function(q){
    cumprobs <- cumsum(dbenford(1:9))
    return(cumprobs[q])
}
```

#### racket

*Racket is a Lisp descended from Scheme (racket-lang.org)*

``` racket
#lang racket

;; draw a graph of cos and deriv^3(cos)
(require plot)
(define ((deriv f) x)
  (/ (- (f x) (f (- x 0.001))) 0.001))
(define (thrice f) (lambda (x) (f (f (f x)))))
(plot (list (function ((thrice deriv) sin) -5 5)
            (function cos -5 5 #:color 'blue)))

;; Print the Greek alphabet
(for ([i (in-range 25)])
  (displayln
   (integer->char
    (+ i (char->integer #\u3B1)))))

;; An echo server
(define listener (tcp-listen 12345))
(let echo-server ()
  (define-values (in out) (tcp-accept listener))
  (thread (λ ()
             (copy-port in out)
             (close-output-port out)))
  (echo-server))
```

#### ruby

aliased as rb

*The Ruby programming language (ruby-lang.org)*

``` rb
class Greeter
  def initialize(name="World")
    @name = name
  end

  def say_hi
    puts "Hi #{@name}!"
  end
end
```

#### rust

aliased as rs

*The Rust programming language (rust-lang.org)*

``` rs
use core::*;

fn main() {
    for ["Alice", "Bob", "Carol"].each |&name| {
        do task::spawn {
            let v = rand::Rng().shuffle([1, 2, 3]);
            for v.each |&num| {
                io::print(fmt!("%s says: '%d'\n", name, num))
            }
        }
    }
}
```

#### sass

*The Sass stylesheet language language (sass-lang.com)*

``` sass
@for $i from 1 through 3
  .item-#{$i}
    width: 2em * $i
```

#### scala

aliased as scala

*The Scala programming language (scala-lang.org)*

``` scala
class Greeter(name: String = "World") {
  def sayHi() { println("Hi " + name + "!") }
}
```

#### scheme

*The Scheme variant of Lisp*

``` scheme
(define Y
  (lambda (m)
    ((lambda (f) (m (lambda (a) ((f f) a))))
     (lambda (f) (m (lambda (a) ((f f) a)))))))
```

#### scss

*SCSS stylesheets (sass-lang.com)*

``` scss
@for $i from 1 through 3 {
  .item-#{$i} {
    width: 2em * $i;
  }
}
```

#### sed

*sed, the ultimate stream editor*

``` sed
/n/,/d/ {
  /n/n # skip over the line that has "begin" on it
  s/old/new/
}
```

#### shell

aliased as bash, zsh, ksh, sh

*Various shell languages, including sh and bash*

``` bash
# If not running interactively, don't do anything
[[ -z "$PS1" ]] && return
```

#### smalltalk

aliased as st, squeak

*The Smalltalk programming language*

``` st
quadMultiply: i1 and: i2 
    "This method multiplies the given numbers by each other
    and the result by 4."
    | mul |
    mul := i1 * i2.
    ^mul * 4
```

#### sml

aliased as ml

*Standard ML*

``` ml
datatype shape
   = Circle   of loc * real      (* center and radius *)
   | Square   of loc * real      (* upper-left corner and side length; axis-aligned *)
   | Triangle of loc * loc * loc (* corners *)
```

#### sql

*Structured Query Language, for relational databases*

``` sql
SELECT * FROM `users` WHERE `user`.`id` = 1
```

#### tcl

*The Tool Command Language (tcl.tk)*

``` tcl
proc cross_sum {s} {expr [join [split $s ""] +]}
```

#### tex

aliased as TeX, LaTeX, latex

*The TeX typesetting system*

``` tex
To write \LaTeX\ you would type \verb:\LaTeX:.
```

#### toml

*the TOML configuration format (https://github.com/mojombo/toml)*

``` toml
# This is a TOML document. Boom.

title = "TOML Example"

[owner]
name = "Tom Preston-Werner"
organization = "GitHub"
bio = "GitHub Cofounder & CEO\nLikes tater tots and beer."
dob = 1979-05-27T07:32:00Z # First class dates? Why not?
```

#### vb

aliased as visualbasic

*Visual Basic*

``` vb
Private Sub Form_Load()
    ' Execute a simple message box that says "Hello, World!"
    MsgBox "Hello, World!"
End Sub
```

#### viml

aliased as vim, vimscript, ex

*VimL, the scripting language for the Vim editor (vim.org)*

``` viml
set encoding=utf-8

filetype off
call pathogen#runtime_append_all_bundles()
filetype plugin indent on
```

#### xml

*<desc for="this-lexer">XML</desc>*

``` xml
<?xml version="1.0" encoding="utf-8"?>
<xsl:template match="/"></xsl:template>
```

#### yaml

aliased as yml

*Yaml Ain't Markup Language (yaml.org)*

``` yaml
---
one: Mark McGwire
two: Sammy Sosa
three: Ken Griffey
```
