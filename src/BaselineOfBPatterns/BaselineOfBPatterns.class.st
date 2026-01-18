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
			package: #'BPatterns-Calypso' with: [ spec requires: #('BPatterns') ];
			package: #'BPatterns-Calypso-Tests' with: [ spec requires: #('BPatterns-Calypso') ];
			package: #'BPatterns-Deprecation' with: [ spec requires: #('BPatterns') ];
			package: #'BPatterns-Deprecation-Tests' with: [ spec requires: #('BPatterns-Deprecation') ].
		spec 
			group: 'Core' with: #('BPatterns' );
			group: 'CoreTests' with: #('BPatterns-Tests');
			group: 'Tools' with: #('BPatterns-Calypso' 'BPatterns-Deprecation');
			group: 'ToolsTests' with: #('BPatterns-Calypso-Tests' 'BPatterns-Deprecation-Tests');
			group: 'default' with: #('Core' 'CoreTests' 'Tools' 'ToolsTests'). 
		].
]
