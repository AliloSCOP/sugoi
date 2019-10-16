package sugoi;

/**
 * Shortcut to system class
 */
#if !macro 
    #if php
    typedef Web = php.Web;
    #else
    typedef Web =  neko.Web;
    #end

#else
    //Web.getCwd() will work in macros
    typedef Web = Sys;
#end