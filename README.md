# mkdocs-architecture-docs

This project is designed for developing architectural documentation using MkDocs with the Material theme. It includes a PlantUML server for rendering diagrams directly within the documentation.

## Project Structure

- **.devcontainer/**: Contains configuration files for the development container.
  - **devcontainer.json**: Configures the development environment.
  - **docker-compose.yml**: Defines the services for MkDocs and PlantUML.

- **docs/**: Contains the documentation files.
  - **index.md**: Main entry point for the documentation.
  - **architecture.md**: Detailed architectural documentation.
  - **diagrams/**: Directory for PlantUML diagrams.
    - **architecture.puml**: PlantUML code for architecture diagrams.

- **mkdocs.yml**: Configuration file for MkDocs, including the PlantUML plugin.

- **requirements.txt**: Lists Python dependencies for the MkDocs project.

- **.gitignore**: Specifies files and directories to be ignored by Git.

## Setup Instructions

1. **Clone the Repository**: 
   ```bash
   git clone <repository-url>
   cd mkdocs-architecture-docs
   ```

2. **Open in Development Container**: 
   Use your preferred development environment to open the project in a containerized setup.

3. **Build and Start Services**: 
   The Docker Compose file will automatically set up the MkDocs and PlantUML services.

4. **Access Documentation**: 
   Once the services are running, you can access the documentation at `http://localhost:8000`.

5. **Edit Documentation**: 
   Modify the Markdown files in the `docs/` directory to update the documentation.

6. **Render Diagrams**: 
   Use the PlantUML server to render diagrams defined in the `diagrams/` directory.

## Usage Guidelines

- Ensure that the PlantUML server is running to render diagrams correctly.
- Use the MkDocs development server for live previews of your documentation changes.
- Follow best practices for documentation to maintain clarity and usability.