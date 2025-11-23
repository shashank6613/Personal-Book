import os

def combine_project_files(output_filename="codebase_dump.txt"):
    """
    Traverses the current directory tree, reads text files, and combines them
    into a single output file with a specific separator.
    """
    
    # The separator requested: 168 asterisks
    separator = "*" * 168
    
    # Get the directory where the script is running
    root_dir = os.getcwd()
    
    print(f"Scanning directory: {root_dir}")
    print(f"Writing output to: {output_filename}\n")

    try:
        with open(output_filename, 'w', encoding='utf-8') as outfile:
            # Walk through the directory tree
            for folder_path, dirs, files in os.walk(root_dir):
                
                # OPTIONAL: Skip common non-code directories to keep output clean
                # You can comment these out if you strictly want EVERYTHING
                if '.git' in dirs:
                    dirs.remove('.git')
                if 'node_modules' in dirs:
                    dirs.remove('node_modules')
                if '__pycache__' in dirs:
                    dirs.remove('__pycache__')

                for file in files:
                    file_path = os.path.join(folder_path, file)
                    
                    # Get relative path for cleaner reading (e.g., ./client/src/App.jsx)
                    relative_path = os.path.relpath(file_path, root_dir)

                    # Skip the output file itself so it doesn't read what it's writing
                    if file == output_filename or file == os.path.basename(__file__):
                        continue

                    try:
                        # Attempt to read the file as text
                        with open(file_path, 'r', encoding='utf-8') as infile:
                            content = infile.read()

                            # Write the Filename followed by 5 newlines 
                            # (1 to end the line + 4 for the gap)
                            outfile.write(f"FILE: {relative_path}\n\n\n")
                            
                            # Write the Contents
                            outfile.write(content)
                            
                            # Write the Separator:
                            # \n before separator to ensure it starts on new line
                            # separator itself
                            # \n after separator to end the line
                            # \n\n\n\n (4 extra newlines) to create the requested space before next file
                            outfile.write(f"\n{separator}\n\n\n")
                            
                            print(f"Processed: {relative_path}")

                    except UnicodeDecodeError:
                        # If the file is binary (like an image or compiled binary), skip it
                        print(f"Skipping binary file: {relative_path}")
                    except Exception as e:
                        print(f"Error reading {relative_path}: {e}")

        print(f"\nSuccess! All contents combined into {output_filename}")

    except Exception as e:
        print(f"Critical error: {e}")

if __name__ == "__main__":
    combine_project_files()
