Class {
	#name : 'BaselineOfBPatterns',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfBPatterns',
	#package : 'BaselineOfBPatterns'
}

{ #category : 'baselines' }
BaselineOfBPatterns >> baseline: spec [
	<baseline>
	spec for: #'common' do: [
		spec
			package: #'BPatterns';
			package: #'BPatterns-Tests' with: [ spec requires: #('BPatterns') ];
			package: #'BPatterns-Deprecation' with: [ spec requires: #('BPatterns') ];
			package: #'BPatterns-Deprecation-Tests' with: [ spec requires: #('BPatterns-Deprecation') ];
			package: #'BPatterns-GtViews' with: [ spec requires: #('BPatterns') ];
			package: #'BPatterns-LepiterSnippet' with: [ spec requires: #('BPatterns' 'BPatterns-GtViews') ];
			package: #'BPatterns-LepiterSnippet-Tests' with: [ spec requires: #('BPatterns-LepiterSnippet') ].
		spec
			group: 'Core' with: #('BPatterns' );
			group: 'CoreTests' with: #('BPatterns-Tests');
			group: 'Tools' with: #('BPatterns-Deprecation');
			group: 'ToolsTests' with: #('BPatterns-Deprecation-Tests');
			group: 'GTViews' with: #('BPatterns-GtViews');
			group: 'LepiterSnippet' with: #('BPatterns-LepiterSnippet');
			group: 'LepiterSnippetTests' with: #('BPatterns-LepiterSnippet-Tests');
			group: 'default' with: #('Core' 'CoreTests' 'Tools' 'ToolsTests' 'GTViews' 'LepiterSnippet' 'LepiterSnippetTests').
		].
]

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
