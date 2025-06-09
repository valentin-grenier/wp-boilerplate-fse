<?php

/**
 * Include all files withinh the inc directory
 * 
 * @return void
 */
foreach (glob(get_template_directory() . '/inc/*.php') as $file) {
    require_once $file;
}
