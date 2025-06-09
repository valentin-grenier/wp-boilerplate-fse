<?php

# Include all files from the inc directory
foreach (glob(get_template_directory() . '/inc/*.php') as $file) {
    require_once $file;
}
