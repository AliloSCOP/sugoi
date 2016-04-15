package sugoi;

/**
 * Shortcut to system class
 * 
 * @author fbarbut<francois.barbut@gmail.com>
 */
#if php
typedef Web = php.Web;
#else
typedef Web =  neko.Web;
#end