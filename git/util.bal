//errors
type RepositoryNotFoundErrorData record {
    string repositoryFullName;
};
type RepositoryNotFoundError error<string, RepositoryNotFoundErrorData>;

