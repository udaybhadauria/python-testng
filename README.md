# Python TestNG Style Project

This project demonstrates how to structure a Python project for TestNG-style testing using `pytest`, `Docker`, `Jenkins`, and `GitHub Actions`.

## Getting Started

1. Clone the repo:
    ```bash
    git clone https://github.com/your-user/python-testng.git
    cd python-testng
    ```

2. Install dependencies:
    ```bash
    make install
    ```

3. Run tests:
    ```bash
    make test
    ```

4. Generate HTML report:
    ```bash
    make report
    ```

5. Build Docker container:
    ```bash
    make docker-build
    ```

6. Run tests inside Docker container:
    ```bash
    make docker-run
    ```

## CI/CD with Jenkins and GitHub Actions

This project includes a Jenkins pipeline (`Jenkinsfile`) and GitHub Actions workflow for continuous integration and deployment. 

- **Jenkins** will trigger tests and push Docker images.
- **GitHub Actions** will run tests on every push or pull request and upload HTML test reports as artifacts.

