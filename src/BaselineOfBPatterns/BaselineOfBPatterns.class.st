Class {
	#name : 'BaselineOfBPatterns',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfBPatterns',
	#package : 'BaselineOfBPatterns'
}

{ #category : 'lepiter' }
BaselineOfBPatterns class >> loadLepiter [
	"Register this repository's lepiter/ folder as a directory of the default logical
	 Lepiter database and reload it, so the BPatterns booklet shows up in Lepiter.
	 Requires the repository to already be loaded into Iceberg (as 'BPatterns')."

	IceRepository registry
		detect: [ :aRepository | aRepository name = 'BPatterns' ]
		ifFound: [ :aRepository |
			| defaultDatabase currentProperties |
			defaultDatabase := LeDatabasesRegistry defaultLogicalDatabase.
			currentProperties := defaultDatabase properties.
			currentProperties
				addRegisteredDirectory: aRepository repositoryDirectory / 'lepiter'.
			defaultDatabase reload ]
		ifNone: [ self inform: 'Repository not found.' ]
]

{ #category : 'baselines' }
BaselineOfBPatterns >> baseline: spec [
	<baseline>
	"This fork's baseline deliberately does not register the upstream
	 BPatterns-Calypso(-Tests) or BPatterns-RewritePreview(-Tests)
	 packages below, even though their source directories are still
	 present under src/ (kept for historical reference, not deleted).
	 Both depend on classic-Pharo-only tooling this GT-focused fork
	 doesn't target - Calypso's own command framework
	 (SycSourceCodeCommand/Cly*) and the classic Changes browser
	 (StChangesBrowserPresenter) respectively - and this fork
	 reimplements their functionality on GT-native tools instead (see
	 IMPLEMENTATION_NOTES.md). Iceberg's package browser may still list
	 these directories as unloaded packages; that's expected, since
	 Metacello/Iceberg only ever loads what is registered here."
	spec for: #'common' do: [
		spec
			package: #'BPatterns';
			package: #'BPatterns-Tests' with: [ spec requires: #('BPatterns') ];
			package: #'BPatterns-Deprecation' with: [ spec requires: #('BPatterns') ];
			package: #'BPatterns-Deprecation-Tests' with: [ spec requires: #('BPatterns-Deprecation') ];
			package: #'BPatterns-GToolkit-Extensions' with: [ spec requires: #('BPatterns') ].
		spec
			group: 'Core' with: #('BPatterns' );
			group: 'CoreTests' with: #('BPatterns-Tests');
			group: 'Tools' with: #('BPatterns-Deprecation');
			group: 'ToolsTests' with: #('BPatterns-Deprecation-Tests');
			group: 'GToolkitExtensions' with: #('BPatterns-GToolkit-Extensions');
			group: 'default' with: #('Core' 'CoreTests' 'Tools' 'ToolsTests' 'GToolkitExtensions').
		]
]
