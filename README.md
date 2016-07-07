# Introduction to Rubix Racing (website)
The ASP code that was inherited and enhanced that holds the bulk of Rubix Racing's website 

It uses iframes extensively to show different pages, has a mix of classic ASP (with VB) and some old webforms.

##Notable files:

##### default.aspx 
Contains things like menus
##### portal.inc
Contains most of the global helper functions as well as data generation ones (e.g. create tables or runner info)
##### MM/PM1.aspx
The Maker page. Arguably the most important page which shows other bookie prices, with the ability to manipulate the SDP 
##### MM/PM2.aspx
The Trader page. Used for betback trading.

##If you are creating a new page..

There is a new project Luxbook.MVC within it that hosts a modern MVC solution with MVC and WebApi endpoints supported.
New pages should be created within the Luxbook.MVC project and use modern coding standards (to be replaced with Tab Tech standards when the time comes..)

