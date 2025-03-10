import PBXProj

extension Generator {
    /// Calculates the `buildSettings` attribute of the `XCBuildConfiguration`
    /// elements used by the `BazelDependencies` target.
    ///
    /// - Parameters:
    ///   - indexImport: The Bazel execution root relative path to the
    ///     `index_import` executable.
    ///   - platforms: The platforms that the project builds for.
    ///   - targetIdsFile: The Bazel execution root relative path to the
    ///     target IDs list file.
    static func bazelDependenciesBuildSettings(
        indexImport: String,
        platforms: [Platform],
        targetIdsFile: String
    ) -> String {
        let sortedPlatforms = Set(platforms).sorted()

        // We have to support only a single platform during Index Build to
        // prevent issues duplicated outputs, but it also has to be a platform
        // that one of the targets uses, otherwise it's not invoked at all.
        // Index Build is so weird...
        let indexingSupportedPlatform = sortedPlatforms.first!

        // The tabs for indenting are intentional
        return #"""
{
				BAZEL_PACKAGE_BIN_DIR = rules_xcodeproj;
				CALCULATE_OUTPUT_GROUPS_SCRIPT = "$(BAZEL_INTEGRATION_DIR)/calculate_output_groups.py";
				INDEXING_SUPPORTED_PLATFORMS__ = "$(INDEXING_SUPPORTED_PLATFORMS__NO)";
				INDEXING_SUPPORTED_PLATFORMS__NO = \#(
                    sortedPlatforms
                        .map(\.rawValue)
                        .joined(separator: " ")
                        .pbxProjEscaped
                );
				INDEXING_SUPPORTED_PLATFORMS__YES = \#(
                    indexingSupportedPlatform.rawValue.pbxProjEscaped
                );
				INDEX_DATA_STORE_DIR = "$(INDEX_DATA_STORE_DIR)";
				INDEX_DISABLE_SCRIPT_EXECUTION = YES;
				INDEX_IMPORT = \#(
                    indexImport
                        .executionRootBasedBuildSettingPath
                        .pbxProjEscaped
				);
				SUPPORTED_PLATFORMS = "$(INDEXING_SUPPORTED_PLATFORMS__$(INDEX_ENABLE_BUILD_ARENA))";
				SUPPORTS_MACCATALYST = YES;
				TARGET_IDS_FILE = \#(
                    targetIdsFile
                        .executionRootBasedBuildSettingPath
                        .pbxProjEscaped
				);
				TARGET_NAME = BazelDependencies;
			}
"""#
    }
}
