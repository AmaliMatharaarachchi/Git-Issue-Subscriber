//errors
type RepositoryNotFoundErrorData record {
    string repo_name;
};
type RepositoryNotFoundError error<string, RepositoryNotFoundErrorData>;

