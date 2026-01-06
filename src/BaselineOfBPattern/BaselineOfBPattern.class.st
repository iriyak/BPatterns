Class {
	#name : 'BaselineOfBPattern',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfBPattern',
	#package : 'BaselineOfBPattern'
}

{ #category : 'baselines' }
BaselineOfBPattern >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		spec 
			package: #'BPattern';
			package: #'BPattern-Tests' with: [ spec requires: #('BPattern') ];
			package: #'BPattern-Calypso' with: [ spec requires: #('BPattern') ];
			package: #'BPattern-Calypso-Tests' with: [ spec requires: #('BPattern-Calypso') ].
		spec 
			group: 'Core' with: #('BPattern' );
			group: 'CoreTests' with: #('BPattern-Tests');
			group: 'Tools' with: #('BPattern-Calypso' );
			group: 'ToolsTests' with: #('BPattern-Calypso-Tests');
			group: 'default' with: #('Core' 'CoreTests' 'Tools' 'ToolsTests'). 
		].
]
