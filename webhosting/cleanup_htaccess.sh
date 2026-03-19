#!/bin/bash                                                                                                                   
                                                                                                                              
# Define the target directory (default is current directory)                                                                  
TARGET_DIR=${1:-.}                                                                                                            
                                                                                                                              
echo "Scanning for .htaccess files in: $(realpath $TARGET_DIR)"                                                               
                                                                                                                              
# 1. Find all .htaccess files                                                                                                 
# Excluding the root directory is often safer, but since you were hacked,                                                     
# it's usually better to clean EVERYTHING and manually restore the root one.                                                  
FILES=$(find "$TARGET_DIR" -type f -name ".htaccess")                                                                         
                                                                                                                              
if [ -z "$FILES" ]; then                                                                                                      
    echo "No .htaccess files found. You're clean!"                                                                            
    exit 0                                                                                                                    
fi                                                                                                                            
                                                                                                                              
echo "Found the following files:"                                                                                             
echo "$FILES"                                                                                                                 
echo "-----------------------------------"                                                                                    
                                                                                                                              
# 2. Check for the force flag                                                                                                 
if [[ "$2" == "--force" ]]; then                                                                                              
    echo "Action: DELETING ALL FOUND FILES..."                                                                                
    find "$TARGET_DIR" -type f -name ".htaccess" -delete                                                                      
    echo "Done. All .htaccess files removed."                                                                                 
else                                                                                                                          
    echo "Safe Mode: No files were deleted."                                                                                  
    echo "Run the script with '--force' to delete them."                                                                      
    echo "Example: ./cleanup_htaccess.sh . --force"                                                                           
