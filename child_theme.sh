#!/bin/bash

# Prompt for the file location
read -p "Enter path to theme from ~ : " file_path

# Prompt for parent theme name
read -p "Enter the name of the parent theme: " parent_theme

# Prompt for child theme name
read -p "Enter the name of the child theme: " child_theme

# Prompt for child theme directory
read -p "Enter the child theme directory name: " child_theme_dir

# Prompt for Theme URI
read -p "Enter the Theme URI: " theme_uri

# Prompt for author
read -p "Enter the author: " author

# Prompt for Author URI
read -p "Enter the Author URI: " author_uri

# Set up variables
theme_file_path="$file_path/$child_theme_dir"
style_css="style.css"
functions_php="functions.php"
sass_dir="sass"
sass_main_file="$sass_dir/style.scss"
sass_components_file="$sass_dir/components/index.scss"
gitignore_file=".gitignore"


# Go to root folder
cd

# Create child theme directory
mkdir -p "$theme_file_path"
cd $theme_file_path


# Create style.css
touch "$style_css"
cat << EOF > "$style_css"
/*
 Theme Name: $child_theme
 Theme URI: $theme_uri
 Description: Child theme for $parent_theme
 Author: $author
 Author URI: $author_uri
 Template: $parent_theme
 Version: 1.0.0
*/

/* Add your custom styles below this line */
EOF

# Create functions.php
touch "$functions_php"
cat << EOF > "$functions_php"
<?php
add_action( 'wp_enqueue_scripts', 'enqueue_parent_styles' );
function enqueue_parent_styles() {
    wp_enqueue_style( '$parent_theme', get_template_directory_uri() . '/style.css' );
}

// Enqueue Sass-generated CSS
add_action( 'wp_enqueue_scripts', 'enqueue_sass_styles' );
function enqueue_sass_styles() {
    wp_enqueue_style( '$child_theme', get_stylesheet_directory_uri() . '/sass/style.css' );
}
EOF

# Create Sass directory and main file
mkdir -p "$sass_dir"
touch "$sass_main_file"

# Append comment block to style.scss
cat << EOF >> "$sass_main_file"
/*
 Theme Name: $child_theme
 Theme URI: $theme_uri
 Description: Child theme for $parent_theme
 Author: $author
 Author URI: $author_uri
 Template: $parent_theme
 Version: 1.0.0
*/

/* Add your custom styles below this line */

@import 'components/index';
EOF

# Create components directory and main.scss
mkdir -p "$sass_dir/components"
touch "$sass_components_file"

# Add placeholder content to components/main.scss
echo "// Import components here" > "$sass_components_file"

# Install Sass compiler using npm
npm init -y
npm install --save-dev node-sass stylelint wp-scripts

# Update package.json scripts
cat << EOF > "package.json"
{
  "name": "$child_theme",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "private": true,
  "scripts": {
    "watch": "node-sass sass/ -o ./ --source-map true --output-style expanded --indent-type tab --indent-width 1 -w",
    "compile:css": "node-sass sass/ -o ./ && stylelint '*.css' --fix || true && stylelint '*.css' --fix",
    "lint:scss": "wp-scripts lint-style sass/**/*.scss"
  },
  "keywords": [],
  "author": "$author",
  "license": "ISC",
  "devDependencies": {
    "node-sass": "^4.14.1",
    "stylelint": "^13.13.1",
    "wp-scripts": "^2.2.5"
  }
}
EOF

# Create .gitignore file
cat << EOF > "$gitignore_file"
node_modules/
.vscode/
EOF

# Initialize Git repository
git init
git add .
git commit -m "Initial commit"

# Create a remote repository on GitHub using the GitHub CLI
gh repo create

# Push the local repository to GitHub
git push origin main

# Success message
echo "WordPress child theme with Sass support created successfully!"
