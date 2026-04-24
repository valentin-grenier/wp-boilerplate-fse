import React from 'react';

export default function Card( { title, children, className = '' } ) {
	return (
		<div className={ `clp-card ${ className }`.trim() }>
			{ title && <h2 className="clp-card__title">{ title }</h2> }
			<div className="clp-card__body">{ children }</div>
		</div>
	);
}
